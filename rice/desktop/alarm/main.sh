#!/usr/bin/env bash
end="$(date "+%s" --date "$*")" || exit 1
foo=0
date --date "@$end"
while sleep "$foo"; do
	foo=1
	now="$(date "+%s")"
	((now < end)) || break
	read -r d h m s <<<"$(date -u +"%j %H %M %S" --date "@$((end - now))")"
	((d--))
	echo -ne "\rwaiting for $d days $h:$m:$s"
done
mpv --ao=pulse --input-commands="set ao-volume 50" "@bell@"
