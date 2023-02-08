#!/usr/bin/env bash
((UID != 0)) && exec sudo "$0"

hw="lo/hardware-configuration.nix"
[ -f "$hw" ] || nixos-generate-config --show-hardware-config > "$hw"

mount \
	none -t overlay \
	-o ro \
	-o lowerdir="$PWD/lo" \
	-o upperdir="$PWD/hi" \
	-o workdir="$PWD/work" \
	/etc/nixos
