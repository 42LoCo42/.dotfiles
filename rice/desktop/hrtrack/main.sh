#!/usr/bin/env bash
src="$HOME/doc/trans/hrtrack"
has="$(<"$src")"
now="$(date "+%Y-%m-%d")"

if [ "$has" = "$now" ]; then
	notify-send "HRT already taken!"
else
	extra=""
	if (($(date +%s) / 86400 % 3 == 0)); then
		extra=" and Cypro"
	fi

	if (($(date +%u) == 6)); then
		extra="$extra and Vitamin D"
	fi

	notify-send -u critical -t 5000 "Take Estrogen$extra today!"
	echo "$now" >"$src"
fi
