#!/usr/bin/env bash
set -euo pipefail

sec="/run/secrets/user/$USER"
win="$(hyprctl activewindow -j)"
pw=""

case "$(jq -r .initialClass <<<"$win")" in
librewolf) pw=bitwarden ;;
Jameica*) pw=jameica ;;
foot)
	pid="$(jq -r .pid <<<"$win")"
	if pstree "$pid" | grep -Eq 'ssh (bunny|laniakea)'; then
		pw=server-admin
	fi
	;;
esac

choose() {
	pw="$(
		(
			cd "$sec/passwords"
			find . -mindepth 1
		) | sed 's|^./||' | fuzzel -d -p 'Select password: '
	)"
}

if [ -n "$pw" ]; then
	answer="$(echo -e "No\nYes" | fuzzel -d -p "Enter password '$pw'? ")"
	case "$answer" in
	Yes) ;;
	No) choose ;;
	esac
else
	choose
fi

age -d -i "$sec/age-nopin" <"$sec/passwords/$pw" | wtype -
