# https://github.com/Malix-Labs/Nix_Remote-Builders-Distributed

# Helper to assert external command prerequisites
def check-cmd [cmd: closure, msg: string] {
	let res = try {
		do $cmd | complete
	} catch { {exit_code: 1} }
	if $res.exit_code != 0 {
		print --stderr $msg
		exit 1
	}
}

# Distribute Nix builds across on-demand cloud runners over Tailscale SSH.
def main [
	--provider: string = "gha" # Cloud provider backend
	--fast # Use nix-fast-build for pipelined eval + remote builds
	--built-in # Force standard nix CLI executor
	--max-runners: int = 4 # Maximum auto-scaled runners
	--runners: int # Force an exact total number of runners
	--x86: int # Force an exact x86_64-linux runner count
	--arm: int # Force an exact aarch64-linux runner count
	--darwin: int # Force an exact aarch64-darwin runner count
	--local-jobs: int = 0 # Local Nix jobs limit (0 offloads all builds to remote)
	--timeout-startup: int = 300 # Seconds to wait for initial runner connection
	--timeout-idle: int = 300 # Seconds of inactivity before runner disconnects
	--timeout-linger: int = 0 # Seconds to keep runner alive after build completion
	--repo: string # Target repository hosting the runner workflow (owner/repo)
	--environment: string # GitHub Actions environment name containing secrets
	--tailscale-tags: string # Tailscale ACL tags to apply to runner nodes
	--keep-alive # Keep runners alive after command finishes
	...rest: string # Nix command and arguments (e.g. build .#default)
] {
	if $fast and $built_in {
		print --stderr "Error: --fast and --built-in are mutually exclusive."
		exit 1
	}

	if ($rest | is-empty) {
		print --stderr "Error: No Nix command specified."
		help main
		exit 1
	}

	let nix_args = if $rest.0 == "nix" {
		$rest | skip 1
	} else {
		$rest
	}

	if ($nix_args | is-empty) {
		print --stderr "Error: No Nix subcommand specified after 'nix'."
		exit 1
	}

	if $provider == "gha" {
		check-cmd { gh auth status } "Error: GitHub CLI ('gh') is not authenticated or not installed.\nPlease run 'gh auth login' or export GITHUB_TOKEN."
	}
	check-cmd { tailscale status } "Error: Tailscale is not running, not authenticated, or not installed.\nPlease run 'tailscale up' or 'tailscale login'."

	let xdg_config = (
		$env.XDG_CONFIG_HOME?
		| default (
			$env.HOME?
			| default "~"
			| path expand
			| path join ".config"
		)
	)
	let config_file = $xdg_config | path join "nix-remote" "config.toml"
	let config_data = if ($config_file | path exists) {
		try {
			open $config_file
		} catch { {} }
	} else {
		{}
	}
	let config_repo = try {
		$config_data | get --optional repo
	} catch { null }
	let config_env = try {
		$config_data | get --optional environment
	} catch { null }
	let config_tags = try {
		$config_data | get --optional tailscale_tags
	} catch { null }

	let target_repo = if $repo != null and ($repo | str length) > 0 {
		$repo
	} else if $config_repo != null and ($config_repo | str length) > 0 {
		$config_repo
	} else {
		let detected = gh repo view --json nameWithOwner -q .nameWithOwner | complete
		if $detected.exit_code == 0 and ($detected.stdout | str trim | is-not-empty) {
			$detected.stdout | str trim
		} else {
			let git_url = if (which git | is-not-empty) {
				(git remote get-url origin | complete)
			} else {
				{exit_code: 1, stdout: ""}
			}
			if $git_url.exit_code == 0 and ($git_url.stdout | str trim | is-not-empty) {
				$git_url.stdout | str trim
			} else {
				print --stderr $"Error: No runner repository specified.\nPlease configure a repository in '($config_file)', use --repo <owner/repo>, or run from inside a git repository."
				exit 1
			}
		}
	}

	let target_env = if $environment != null and ($environment | str length) > 0 {
		$environment
	} else if $config_env != null and ($config_env | str length) > 0 {
		$config_env
	} else {
		null
	}

	let target_tags = if $tailscale_tags != null and ($tailscale_tags | str length) > 0 {
		$tailscale_tags
	} else if $config_tags != null and ($config_tags | str length) > 0 {
		$config_tags
	} else {
		"tag:nix-builder"
	}

	mut x86_cnt = 0
	mut arm_cnt = 0
	mut darwin_cnt = 0

	if $x86 != null or $arm != null or $darwin != null {
		$x86_cnt = ($x86 | default 0)
		$arm_cnt = ($arm | default 0)
		$darwin_cnt = ($darwin | default 0)
		print $"Using explicit runner configuration: ($x86_cnt) x86, ($arm_cnt) ARM, ($darwin_cnt) Darwin"
	} else if $runners != null {
		$x86_cnt = $runners
		$arm_cnt = 0
		$darwin_cnt = 0
		print $"Using explicit runner count: ($x86_cnt) x86"
	} else {
		print "Evaluating build requirements..."

		let is_flake_check = ($nix_args.0 == "flake" and ($nix_args.1? == "check"))

		mut unbuilt_systems = []
		if $is_flake_check {
			let eval_res = (
				nix-eval-jobs --check-cache-status --force-recurse --flake . --select "flake: (flake.outputs.checks or {})"
				| complete
			)
			if $eval_res.exit_code == 0 and ($eval_res.stdout | str trim | is-not-empty) {
				$unbuilt_systems = ($eval_res.stdout
					| lines
					| where ($it | str starts-with "{")
					| each {|l| try { $l | from json } catch { null } }
					| where $it != null and ($it.fatal? != true) and ((not ($it.isCached? | default false)))
					| get --optional system
					| compact
				)
			}
		} else {
			let dry_args = if $nix_args.0 == "build" {
				[...$nix_args, "--dry-run", "--json"]
			} else {
				[
					"build"
					...($nix_args | skip 1)
					"--dry-run"
					"--json"
				]
			}
			let dry_res = (^nix ...$dry_args | complete)
			if $dry_res.exit_code != 0 {
				print --stderr $dry_res.stderr
				exit $dry_res.exit_code
			}
			let drvs = try {
				$dry_res.stdout | from json | get --optional drvPath | compact
			} catch { [] }

			if ($drvs | is-not-empty) {
				let drv_info = (
					^nix derivation show ...$drvs
					| complete
					| get stdout
					| from json
				)
				$unbuilt_systems = ($drv_info | values | get system)
			}
		}

		let unbuilt_count = $unbuilt_systems | length

		if $unbuilt_count == 0 {
			print "All derivations are cached. No remote builders needed.\nExecuting locally..."
			^nix ...$nix_args
			return
		}

		let x86_unbuilt = $unbuilt_systems | where $it == "x86_64-linux" | length
		let arm_unbuilt = $unbuilt_systems | where $it == "aarch64-linux" | length
		let darwin_unbuilt = $unbuilt_systems | where $it == "aarch64-darwin" | length

		let scale_for = {|count: int|
			if $count <= 0 { 0 } else if $count <= 1 { 1 } else if $count <= 4 { 2 } else if $count <= 8 { 3 } else { $max_runners }
		}

		$x86_cnt = (do $scale_for $x86_unbuilt)
		$arm_cnt = (do $scale_for $arm_unbuilt)
		$darwin_cnt = (do $scale_for $darwin_unbuilt)

		if $x86_cnt == 0 and $arm_cnt == 0 and $darwin_cnt == 0 {
			$x86_cnt = 1
		}

		let total_unscaled = $x86_cnt + $arm_cnt + $darwin_cnt
		if $total_unscaled > $max_runners {
			let non_x86 = (if $arm_cnt > 0 { 1 } else { 0 }) + (if $darwin_cnt > 0 { 1 } else { 0 })
			$arm_cnt = (if $arm_cnt > 0 { 1 } else { 0 })
			$darwin_cnt = (if $darwin_cnt > 0 { 1 } else { 0 })
			$x86_cnt = [
				($max_runners - $non_x86)
				1
			] | math max
		}

		print $"Build analysis: ($unbuilt_count) unbuilt \(x86: ($x86_unbuilt), arm: ($arm_unbuilt), darwin: ($darwin_unbuilt)\), allocating ($x86_cnt) x86_64, ($arm_cnt) aarch64, ($darwin_cnt) aarch64-darwin"
	}

	let total_runners = $x86_cnt + $arm_cnt + $darwin_cnt
	if $total_runners <= 0 {
		$x86_cnt = 1
	}

	# see https://codeberg.org/wvhulle/nu-lint/issues/114
	# nu-lint-ignore: nu_parse_error
	let session_id = $"b(random chars --length 6 | str lowercase)"

	let nodes = [
		...(
			0..<$x86_cnt
			| each {|i| { id: $"x86-($i)", os: "ubuntu-latest", system: "x86_64-linux", cores: 4, host: $"nix-builder-($session_id)-x86-($i)" } }
		)
		...(
			0..<$arm_cnt
			| each {|i| { id: $"arm-($i)", os: "ubuntu-26.04-arm", system: "aarch64-linux", cores: 4, host: $"nix-builder-($session_id)-arm-($i)" } }
		)
		...(
			0..<$darwin_cnt
			| each {|i| { id: $"darwin-($i)", os: "macos-latest", system: "aarch64-darwin", cores: 3, host: $"nix-builder-($session_id)-darwin-($i)" } }
		)
	]
	let matrix_json = ({
		include: ($nodes | select id os)
	} | to json --raw)

	let do_cleanup = {|hosts: list<any>, keep: bool|
		if not $keep {
			print "\nShutting down remote builders..."
			$hosts | par-each {|node|
		ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=3 $"runner@($node.host).bunny.vpn" "touch /tmp/nix-builder-done" | complete
	  }
		} else {
			print "\nKeep-alive enabled. Builders will stay running until their timeout."
		}
	}

	let target_desc = ['nix' ...$nix_args] | str join ' '

	if $provider == "gha" {
		let env_log = if $target_env != null { $"\n  Environment: ($target_env)" } else { "" }
		print $"\nDispatching GitHub Actions workflow on ($target_repo)...($env_log)\n  Tailscale Tags: ($target_tags)\n  Session: ($session_id)\n  Target: ($target_desc)\n  Total builders: ($nodes | length) \(x86: ($x86_cnt), arm: ($arm_cnt), darwin: ($darwin_cnt)\)"

		mut gh_args = [
			workflow
			run
			nix-builder.yaml
			--repo
			$target_repo
			-f
			$"session_id=($session_id)"
			-f
			$"target=($target_desc)"
			-f
			$"matrix=($matrix_json)"
			-f
			$"tailscale_tags=($target_tags)"
			-f
			$"timeout_startup=($timeout_startup)"
			-f
			$"timeout_idle=($timeout_idle)"
			-f
			$"timeout_linger=($timeout_linger)"
		]

		if $target_env != null {
			$gh_args ++= [-f $"environment=($target_env)"]
		}

		let dispatch_res = gh ...$gh_args | complete
		if $dispatch_res.exit_code != 0 {
			print --stderr $"Error dispatching workflow: ($dispatch_res.stderr)"
			do $do_cleanup $nodes false
			exit 1
		}
	} else {
		print --stderr $"Error: Unsupported provider '($provider)'."
		do $do_cleanup $nodes false
		exit 1
	}

	print "\nWaiting for builders to join Tailnet (Tailscale SSH)..."
	let start_time = (date now)
	mut ready_nodes = []

	while ($ready_nodes | length) < ($nodes | length) {
		let elapsed = ((date now) - $start_time) // 1sec
		if $timeout_startup > 0 and $elapsed >= $timeout_startup {
			print --stderr $"\nError: Timed out waiting for runners after ($timeout_startup)s."
			do $do_cleanup $nodes false
			exit 1
		}

		if $provider == "gha" {
			let failed = try {
				gh run list --repo $target_repo --limit 5 --json databaseId,status,conclusion,displayTitle
				| from json
				| where status == "completed" and conclusion in [failure cancelled startup_failure timed_out] and ($it.displayTitle? | default "" | str contains $"[($session_id)]")
				| first
			}
			if $failed != null {
				print --stderr $"\nError: GitHub Actions workflow run failed with conclusion '($failed.conclusion)'.\nView logs: https://github.com/($target_repo)/actions/runs/($failed.databaseId)"
				do $do_cleanup $nodes false
				exit 1
			}
		}

		let newly_ready = ($nodes
		| where not ($it in $ready_nodes)
		| par-each {|node|
			let probe = ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=2 -o BatchMode=yes $"runner@($node.host).bunny.vpn" "base64 -w0 /etc/ssh/ssh_host_ed25519_key.pub" | complete
			if ($probe.exit_code == 0) {
				{...$node, key: $probe.stdout}
			} else {
				null
			}
		} | compact)

		for node in $newly_ready {
			$ready_nodes ++= [$node]
			print $"  Builder online: ($node.host) \(($node.system)\)"
		}

		if ($ready_nodes | length) < ($nodes | length) {
			sleep 5sec
		}
	}

	print $"\nAll ($ready_nodes | length) builders online."

	let builders_list = ($ready_nodes | each {|node|
		$"ssh-ng://runner@($node.host).bunny.vpn?remote-program=/nix/var/nix/profiles/default/bin/nix-daemon ($node.system) - ($node.cores) 1 kvm,benchmark,big-parallel - ($node.key)"
	})
	let builders_arg = $builders_list | str join ";"

	let use_fast = if $fast {
		true
	} else if $built_in {
		false
	} else {
		# Sane automatic default:
		# Use fast (nix-fast-build) for flake check or batch attribute builds (.#checks, .#packages)
		let is_check = ($nix_args.0 == "flake" and ($nix_args.1? == "check"))
		let is_batch = ($nix_args | any {|a|
			($a | str starts-with ".#checks") or ($a | str starts-with ".#packages") or ($a | str starts-with ".#legacyPackages")
		})
		let is_unsupported_subcmd = ($nix_args.0 in ["run", "shell", "develop"])

		($is_check or $is_batch) and (not $is_unsupported_subcmd)
	}

	if $use_fast {
		let flake_target = if ($nix_args.0 == "flake") and ($nix_args.1? == "check") {
			".#checks"
		} else if ($nix_args.0 == "build") and (($nix_args | length) > 1) {
			$nix_args.1
		} else {
			".#checks"
		}

		print $"\nRunning with nix-fast-build: flake target '($flake_target)'\n"

		try {
			sudo nix-fast-build --flake $flake_target --option builders $builders_arg --option max-jobs ($local_jobs | into string) --no-nom
			do $do_cleanup $nodes $keep_alive
		} catch {|err|
			do $do_cleanup $nodes $keep_alive
			error make --unspanned {msg: $"nix-fast-build failed: ($err.msg)"}
		}
	} else {
		print $"\nRunning: nix ($nix_args | str join ' ')\n"

		try {
			^sudo nix -L ...$nix_args --builders $builders_arg --max-jobs $local_jobs
			do $do_cleanup $nodes $keep_alive
		} catch {|err|
			do $do_cleanup $nodes $keep_alive
			error make --unspanned {msg: $"Nix build failed: ($err.msg)"}
		}
	}
}
