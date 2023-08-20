#!/usr/bin/env bash
@brightnessctl@ -m info \
| awk -F ',' '{sub(/%/, "", $4); print $4 '"$1"' "%"}' \
| @brightnessctl@ set "$(cat)"
