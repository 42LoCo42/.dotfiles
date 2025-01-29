#!/usr/bin/env bash
set -eEuo pipefail

case "$1" in
info)
	if [ "$(mpc status "%state%")" == "stopped" ]; then
		cat <<-EOF
			{
				"cover": "/tmp/music-cover.png",
				"name": "Stopped",
				"position": ""
			}
		EOF
		exit
	fi

	oldfile="/tmp/music-file"
	touch "$oldfile"

	file="$HOME/music/$(mpc current -f "%file%")"
	if [ "$file" != "$(<"$oldfile")" ]; then
		echo "$file" >"$oldfile"
		ffmpeg \
			-i "$file" \
			-vf "crop=w='min(iw\,ih)':h='min(iw\,ih)',scale=500:500,setsar=1" \
			-y "/tmp/music-cover.png"
	fi

	{
		mpc current -f "%title%\n%artist%\n%album%\n%track%"
		find "$(dirname "$file")" -maxdepth 1 -type f | grep -Ecv '\.(png|jpg|webp)$'
		mpc status "%songpos%\n%length%"
	} | jq -Rs 'split("\n") | {
		# 0: title
		# 1: artist
		# 2: album
		# 3: apos (position of song in album)
		# 4: alen (length of album)
		# 5: qpos (position of song in queue)
		# 6: qlen (length of queue)

		# hack to make eww always refresh cover
		cover: "/tmp/music-cover.png",

		name: "\(.[0])\(      # title
			if .[1] != ""     # if song has known artist:
			then " - \(.[1])" # - artist
			else "" end)",

		position: "\(
			if .[2] != ""                       # if song has known album:
			then "\(.[2]) - \(.[3])/\(.[4]) | " # album - alen/apos |
			else "" end)\(.[5])/\(.[6])",       # qpos/qlen
	}'
	;;
time-text)
	mpc status "%currenttime% / %totaltime%"
	;;
time-perc)
	mpc status "%percenttime%" | tr -d ' %'
	;;
esac
