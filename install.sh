#!/usr/bin/env bash
set -e
echo "Installing primary dependencies..."
sudo pacman -S --needed --noconfirm base-devel git

if ! command -v yay >/dev/null; then
	yay="$HOME/yay-bin"
	git clone https://aur.archlinux.org/yay-bin "$yay"
	pushd "$yay" || exit 1
	makepkg -cfi --noconfirm
	popd
	rm -rf "$yay"
fi

if ! command -v rcup >/dev/null; then
	yay -S --noconfirm rcm
fi

exec rcup
