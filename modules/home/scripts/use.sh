#!/usr/bin/env bash

# get nixpkgs flake path currently in use by the system
# this removes the need to download nixpkgs everytime nix shell is executed
# shellcheck disable=SC2016
nixpkgs="$(nix eval --raw --impure --expr '"${(builtins.getFlake "'"$HOME/config"'").inputs.nixpkgs}"')"

pkgs=()
for pkg in "$@"; do
	# prepend our nixpkgs path if the argument is just a package name
	grep -q '#' <<< "$pkg" || pkg="$nixpkgs#$pkg"
	pkgs+=("$pkg")
done

exec nix shell "${pkgs[@]}"
