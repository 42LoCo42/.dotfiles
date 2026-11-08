#!/usr/bin/env bash
if pid="$(pgrep lsyncd)"; then
	notify-send "sync-manager" "Stopped!"
	kill "$pid"
else
	if [ ! -S "$HOME/.ssh/control-bunny" ]; then
		notify-send "sync-manager" "Authenticate!"
		ssh -fMN bunny
	fi

	notify-send "sync-manager" "Started!"
	exec lsyncd -nodaemon @config@
fi
