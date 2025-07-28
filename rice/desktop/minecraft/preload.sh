#!/usr/bin/env bash
dir="$HOME/.local/share/FjordLauncher"
mkdir -pv "$dir"

file="$dir/accounts.json"
if [ ! -e "$file" ]; then
	cat <<-EOF >"$file"
		{
			"accounts": [
				{
					"active": true,
					"entitlement": {
						"canPlayMinecraft": true,
						"ownsMinecraft": true
					},
					"type": "MSA"
				}
			],
			"formatVersion": 3
		}
	EOF

	echo "Injected stub MS account! Fuck DRM :3"
fi
