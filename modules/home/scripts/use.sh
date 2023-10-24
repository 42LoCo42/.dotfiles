#!/usr/bin/env bash

pkgs=()
for pkg in "$@"; do
	# prepend our nixpkgs path if the argument is just a package name
	grep -q '#' <<< "$pkg" || pkg="@nixpkgs@#$pkg"
	echo "Using $pkg"
	pkgs+=("$pkg")
done

export IN_USE_SHELL=1
exec nix shell "${pkgs[@]}"
