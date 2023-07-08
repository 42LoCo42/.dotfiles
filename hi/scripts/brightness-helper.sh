#!/usr/bin/env bash
"$1/bin/brightnessctl" -m info \
| awk -F ',' '{sub(/%/, "", $4); print $4 '"$2"' "%"}' \
| "$1/bin/brightnessctl" set "$(cat)"
