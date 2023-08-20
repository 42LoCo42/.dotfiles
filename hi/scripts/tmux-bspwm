#!/usr/bin/env bash
# https://www.reddit.com/r/tmux/comments/j7fcr7/tiling_in_tmux_as_in_bspwm
cmd="$(tmux display -p '8 * #{pane_width} - 20 * #{pane_height}')"
if (($cmd < 0)); then
	arg="-v"
else
	arg="-h"
fi
tmux splitw "$arg" -c '#{pane_current_path}'
