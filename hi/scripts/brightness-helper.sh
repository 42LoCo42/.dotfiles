#!/usr/bin/env bash
brightnessctl="$1"
"$brightnessctl" -m info \
| awk -F ',' '{sub(/%/, "", $4); print $4 '"$2"' "%"}' \
| "$brightnessctl" set "$(cat)"
