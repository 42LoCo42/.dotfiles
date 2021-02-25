#!/usr/bin/env sh
# shellcheck disable=SC1090
for f in "$HOME/.config/profile.d"/*; do
	. "$f"
done
