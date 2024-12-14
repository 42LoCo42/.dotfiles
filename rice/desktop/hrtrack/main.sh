#!/usr/bin/env bash
if tty >/dev/null; then
	out="echo"
else
	out="notify-send"
fi

src="$HOME/doc/trans/hrtrack"
has="$(<"$src")"
now="$(date "+%Y-%m-%d")"
echo "Today is $now"
if [ "$has" == "$now" ]; then
	"$out" "HRT already taken!"
else
	extra=""
	if (($(date +%s) / 86400 % 3 == 0)); then
		extra=" and Cypro"
	fi

	if (($(date +%u) == 6)); then
		extra="$extra and Vitamin D"
	fi

	"$out" "Take Estrogen$extra today!"
	echo "$now" >"$src"
fi
