#!/usr/bin/env bash
if tty >/dev/null; then
	out="echo"
else
	out="notify-send"
fi

src="/persist/$HOME/ARCH/trans/hrtrack"
has="$(< "$src")"
now="$(date "+%Y-%m-%d")"
echo "Today is $now"
if [ "$has" == "$now" ]; then
	"$out" "HRT already taken!"
else
	extra=""
	if (($(date +%s) / 86400 % 2 == 1)); then
		extra=" and Cypro"
	fi

	"$out" "Take Estrogen$extra today!"
	echo "$now" > "$src"
fi
