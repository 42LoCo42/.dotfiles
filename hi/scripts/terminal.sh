#!/usr/bin/env bash

# if not in workspace 0, move there
ws="$(swaymsg -t get_workspaces | jq '.[] | select(.focused).num')"
if ((ws != 0)); then
	swaymsg workspace 0
	no_move=1
fi

# if there is a window selected:
windows=$(swaymsg -t get_workspaces | jq '.[] | select(.num == 0).focus | length')
if ((windows > 0)); then
	# then move unless we already did that
	((no_move)) || swaymsg workspace back_and_forth
else
	# else start a new terminal

	# shellcheck disable=SC2016
	# $term should expand in sway, not here
	swaymsg exec '$term' "tmux new-session -A -s 0"
fi
