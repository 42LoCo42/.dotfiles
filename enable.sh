#!/usr/bin/env bash
((UID != 0)) && exec sudo "$0"

files=(configuration.nix flake.nix flake.lock)
out="/etc/nixos"

for f in "${files[@]}"; do
	target="$out/$f"
	umount -q "$target"
	mount -o ro,bind "$f" "$target"
done

mkdir -p "$out/extra"
mount -o ro,bind extra "$out/extra"

nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix
