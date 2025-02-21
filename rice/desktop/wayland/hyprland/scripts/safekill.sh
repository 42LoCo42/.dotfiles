#!/usr/bin/env bash
json="$(hyprctl activewindow -j)"
class="$(jq -r .class <<<"$json")"
initialTitle="$(jq -r .initialTitle <<<"$json")"

if [ "$class" = "firefox" ] && [ "$initialTitle" = "Mozilla Firefox" ]; then
	hyprctl dispatch sendshortcut "ctrl, q,"
else
	hyprctl dispatch killactive
fi
