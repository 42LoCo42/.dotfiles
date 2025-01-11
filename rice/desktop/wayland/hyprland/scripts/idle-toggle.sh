#!/usr/bin/env bash
if systemctl --user is-active hypridle; then
	systemctl --user stop hypridle
	notify-send "Idle disabled!"
else
	systemctl --user start hypridle
	notify-send "Idle enabled!"
fi
