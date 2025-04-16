#!/usr/bin/env bash
set -eEuo pipefail
curl -s -K <(
	cat <<-EOF
		-H "Authorization: Bearer $(<"@keyFile@")"
	EOF
) "http://localhost:8384/rest/db/status?folder=@folder@" |
	jq -r 'if .state == "idle" then empty else
		"\(.state) - \(100 * .inSyncFiles / .globalFiles)" end'
