#!/usr/bin/env bash

name="1"
should_move=1

# if not in terminal workspace, move there
ws="$(hyprctl -j activeworkspace | jq -r '.name')"
[ "$ws" != "$name" ] && {
	hyprctl dispatch workspace "$name"
	should_move=0
}

# if there are no windows: create a terminal
# else if we should move: do that
windows="$(hyprctl -j activeworkspace | jq '.windows')"
if ((windows == 0)); then
	foot tmux new-session -A -s 0 &
elif ((should_move)); then
	hyprctl dispatch workspace previous
fi
