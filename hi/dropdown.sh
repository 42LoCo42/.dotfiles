#!/usr/bin/env bash
(($# < 1)) && echo "Usage: $0 <cmd> [args...]" && exit 1
title="dropdown-$1"

json="$(swaymsg -t get_tree | jq '.. | select(.app_id? == "'"$title"'")')"

if [ -z "$json" ]; then
	swaymsg "exec \$term -a $title $*"
else
	if [ "$(jq '.visible' <<< "$json")" == "true" ]; then
		swaymsg '[app_id="'"$title"'"] move window to scratchpad'
	else
		swaymsg '[app_id="'"$title"'"] move window to workspace current'
		swaymsg '[app_id="'"$title"'"] focus'
	fi
fi
