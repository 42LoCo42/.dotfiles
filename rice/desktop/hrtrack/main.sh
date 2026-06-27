#!/usr/bin/env bash
set -euo pipefail

# only activate in the evening
hour="$(date +%-H)"
if ((4 < hour && hour < 20)); then exit; fi

extra=""
if (($(date +%s) / 86400 % 6 == 0)); then
	extra=" and Cypro"
fi

mesg="$(printf 'Take Estrogen%s!' "$extra")"
echo -e 'Done\0icon\x1fhrtrack' | fuzzel -d \
	--mesg "$mesg" --mesg-mode expand \
	--message-color '#ebdbb2ff' \
	--hide-prompt --minimal-lines
