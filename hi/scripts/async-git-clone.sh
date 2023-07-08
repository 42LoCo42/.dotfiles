#!/usr/bin/env bash
while read -r src dst options; do
	mkdir -p "$dst"
	[ -d "$dst/.git" ] || git clone "$src" "$dst" $options
done <<EOF
git@github.com:42LoCo42/.dotfiles    $HOME/dotfiles      -b nixos
git@github.com:42LoCo42/emacs-config $HOME/.config/emacs
EOF
