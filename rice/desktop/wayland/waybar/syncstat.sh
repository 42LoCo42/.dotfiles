#!/usr/bin/env bash
set -eEuo pipefail

apikey="$(
	xq -r '.configuration.gui.apikey' \
		<"$HOME/.local/state/syncthing/config.xml"
)"

while sleep 1; do
	curl -s -K <(
		cat <<-EOF
			-H "Authorization: Bearer $apikey"
		EOF
	) "http://localhost:8384/rest/db/status?folder=@folder@" |
		jq -r 'if .state == "idle" then "" else
			"\(.state) - \(100 * .inSyncFiles / .globalFiles)" end'
done
