#!/usr/bin/env bash
case "$1" in
	change) @pulsemixer@ --change-volume "$2" ;;
	mute)   @pulsemixer@ --toggle-mute ;;
	micmute)
		id="$(
			@pulsemixer@ --list-sources \
			| grep Default \
			| tr ',' '\n' \
			| awk 'NR == 1 {print $3}'
		)"
		@pulsemixer@ --toggle-mute --id "$id"
	;;
	play) @mpc@ toggle ;;
	prev) @mpc@ prev ;;
	next) @mpc@ next ;;
	*)    echo "Unknown operation $1!" >&2 ;;
esac
