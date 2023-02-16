#!/usr/bin/env bash
((UID != 0)) && exec sudo -E "$0"

: "${root:=/mnt}"
hw="lo/hardware-configuration.nix"
mkdir -pv "$(dirname "$hw")" "work"
nixos-generate-config --root "$root" --show-hardware-config > "$hw"

dir="$root/etc/nixos"
mkdir -pv "$dir"
mount \
	none -t overlay \
	-o lowerdir="$PWD/lo" \
	-o upperdir="$PWD/hi" \
	-o workdir="$PWD/work" \
	"$dir"

nixos-install --flake "$dir#nixos"
