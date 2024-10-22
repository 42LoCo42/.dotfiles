#!/usr/bin/env bash
(($# < 1)) && echo "Usage: $0 <cmd> [args...]" && exit 1

current_ws="$(hyprctl -j activeworkspace | jq -r ".name")"
hidden_ws="special"
class="dropdown_$1"

# find a window with our target class
window="$(
	hyprctl -j clients \
	| jq "map(select(.class == \"$class\")) | .[0]"
)"

if [ "$window" == "null" ]; then
	# no window found, create it
	foot -a "$class" "$@" &
else
	# window found
	address="$(jq -r '.address' <<< "$window")"
	window_ws="$(jq -r '.workspace.name' <<< "$window")"

	if [ "$window_ws" == "$current_ws" ]; then
		# window is on current workspace
		# send to hidden workspace
		hyprctl dispatch movetoworkspacesilent "$hidden_ws,address:$address"
	else
		# window is somewhere else
		# bring to current workspace & focus
		hyprctl dispatch movetoworkspacesilent "$current_ws,address:$address"
		hyprctl dispatch focuswindow "address:$address"
	fi
fi
