#!/usr/bin/env bash
dir="$XDG_RUNTIME_DIR"
[ -d "$dir" ] || {
	echo "Error: $XDG_RUNTIME_DIR must be a directory!" >&2
	exit 1
}

set -e

out="$dir/screenshot.png"

rm -f "$out"
flameshot gui -p "$out"
wl-copy < "$out"
