#!/usr/bin/env bash
class="$(hyprctl activewindow -j | jq -r '.class')"
if [ "$class" = "firefox" ]; then
	hyprctl dispatch sendshortcut "ctrl, q,"
else
	hyprctl dispatch killactive
fi
