#!/usr/bin/env bash
((UID != 0)) && exec sudo "$0"

hw="lo/hardware-configuration.nix"
mkdir -pv "$(dirname "$hw")" "work"
nixos-generate-config --show-hardware-config > "$hw"
systemctl restart etc-nixos.mount
