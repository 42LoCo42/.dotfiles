#!/usr/bin/env bash
src="$HOME/doc/trans/hrtrack"
has="$(<"$src")"
now="$(date -I)"

if [ "$has" = "$now" ]; then
	notify-send "HRT already taken!"
else
	extra=""
	if (($(date +%s --date "$now") / 86400 % 6 == 0)); then
		extra=" and Cypro"
	fi

	if (($(date +%u --date "$now") == 6)); then
		extra="$extra and Vitamin D"
	fi

	notify-send -u critical -t 5000 "Take Estrogen$extra today!"
	echo "$now" >"$src"
fi
