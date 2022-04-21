#!/usr/bin/env bash
set -e
echo "Installing primary dependencies..."
sudo pacman -S --needed --noconfirm base-devel git

if ! command -v yay >/dev/null; then
	git clone https://aur.archlinux.org/yay-bin
	cd yay-bin || exit 1
	makepkg -cfi --noconfirm
	cd ..
	rm -rf yay-bin
fi

if ! command -v rcup >/dev/null; then
	yay -S --noconfirm rcm
fi

exec rcup
