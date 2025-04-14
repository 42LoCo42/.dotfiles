#!/usr/bin/env bash

name="1"
should_move=1

# if not in terminal workspace, move there
ws="$(hyprctl -j activeworkspace | jq -r '.name')"
[ "$ws" != "$name" ] && {
	hyprctl dispatch workspace "$name"
	should_move=0
}

# if the main terminal is *not* present: create it
# else if we should move: do that
present="$(hyprctl -j clients | jq -c '.[] | select(.class == "foot-main-terminal" and .workspace.name == "'"$name"'")' | wc -l)"
if ((1 - present)); then
	hyprctl dispatch exec "[workspace $name] foot -a foot-main-terminal tmux new-session -A -s 0"
elif ((should_move)); then
	hyprctl dispatch workspace previous
fi
