#!/usr/bin/env bash
set -e
echo "Evaluating configuration..."
new="$("@nom@" \
	build --no-link --print-out-paths \
	"path:$HOME/config#nixosConfigurations.$(hostname).config.system.build.toplevel")"
"@nvd@" diff "/run/current-system" "$new"
# read -rp "Switch to configuration? [y/N]"
# [ "${REPLY,,}" == "y" ] && \
read -rp "Press ENTER to confirm or ctrl-c to cancel"
sudo "$new/bin/switch-to-configuration" switch
