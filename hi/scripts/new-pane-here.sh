#!/usr/bin/env bash
pid="$(
	tmux list-panes -F '#{pane_active} #{pane_pid}' \
	| awk '/^1/ {print $2}'
)"
cwd="$(realpath "/proc/$pid/cwd")"
tmux split-window "$1"
tmux send-keys 'cd "'"$cwd"'"' Enter
