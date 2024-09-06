#!/usr/bin/env bash
run() {
	name="${1##*/}"
	type="${name##*.}"
	time="$(sed -E 's|^[^_]+_(....)(..)(..)_(..)(..)(..).*|\1:\2:\3 \4:\5:\6|' <<<"$name")"
	echo "$1 $type $time"

	case "$type" in
	jpg)
		exiftool -overwrite_original_in_place \
			"-CreateDate=$time" \
			"$1"
		;;
	mp4)
		exiftool -overwrite_original_in_place \
			"-CreateDate=$time" \
			"-TrackCreateDate=$time" \
			"-MediaCreateDate=$time" \
			"$1"
		;;
	*)
		echo "[1;31munsupported type $type![m"
		;;
	esac
}
export -f run

find "$1" -type f | parallel run
