#!/usr/bin/env bash
prompt="$1"
shift
echo -e "No\nYes" \
| @fuzzel@ -p "$prompt " -d \
| grep -q "Yes" && exec "$@"
