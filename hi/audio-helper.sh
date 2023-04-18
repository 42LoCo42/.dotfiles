#!/usr/bin/env bash
pulsemixer="$1/bin/pulsemixer"
mpc="$1/bin/mpc"

case "$2" in
	change) "$pulsemixer" --change-volume "$3" ;;
	mute)   "$pulsemixer" --toggle-mute ;;
	micmute)
		id="$(
			"$pulsemixer" --list-sources \
			| grep Default \
			| tr ',' '\n' \
			| awk 'NR == 1 {print $3}'
		)"
		"$pulsemixer" --toggle-mute --id "$id"
	;;
	play) "$mpc" toggle ;;
	prev) "$mpc" prev ;;
	next) "$mpc" next ;;
	*)    echo "Unknown operation $2!" >&2 ;;
esac
