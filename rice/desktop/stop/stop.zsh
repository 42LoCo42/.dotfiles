#!/usr/bin/env zsh
set -euo pipefail
zmodload zsh/datetime

tput civis
stty -echo

TRAPINT() {
	doSplit
	tput cnorm
	stty echo
	exit
}

printTime() {
	ms="$(($1 * 1000))"
	printf "${2-}%02d:%02d:%02d.%03d${3-}" \
		"$(((ms / (1000 * 60 * 60)) % 60))" \
		"$(((ms / (1000 * 60)) % 60))" \
		"$(((ms / 1000) % 60))" \
		"$((ms % 1000))"
}

doSplit() {
	now="$EPOCHREALTIME"
	printTime "$((now - split))" " - " "\n"
	split="$now"
}

start="$EPOCHREALTIME"
split="$start"

while true; do
	if read -r -t 0.05; then
		doSplit
	else
		printTime "$((EPOCHREALTIME - start))" "\r"
	fi
done
