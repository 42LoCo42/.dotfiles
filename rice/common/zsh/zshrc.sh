sudo() {
	cmd="$1"
	shift
	args=("$@")

	while val="$(alias_value "$cmd")"; do
		echo "expanding to $val" >/dev/tty
		parts=(${(@s/ /)val})
		new="${parts[1]}"
		args=("${parts[@]:1}" "${args[@]}")
		if [ "$cmd" = "$new" ]; then break; fi
		cmd="$new"
	done

	command sudo "$cmd" "${args[@]}"
}

# help for builtins
unalias run-help
autoload run-help
alias help=run-help
