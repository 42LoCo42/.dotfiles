#!/usr/bin/env bash
((UID != 0)) && exec sudo "$0"

hw="lo/hardware-configuration.nix"
[ -f "$hw" ] || nixos-generate-config --show-hardware-config > "$hw"

mount \
	none -t overlay \
	-o ro \
	-o lowerdir=lo \
	-o upperdir=hi \
	-o workdir=work \
	/etc/nixos
