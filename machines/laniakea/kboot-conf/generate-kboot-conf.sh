#!/usr/bin/env bash
tmp="$(mktemp -d)"

pfxcopy() {
	name="$(realpath "$1" | cut -b 12-43)-$(basename "$1")"
	cp "$1" "$tmp/$name"
	echo "$DEST/$name"
}

addEntry() {
	label="nixos-$2-$(<"$1/nixos-version")"
	init="$(realpath "$1/init")"
	params="$(<"$1/kernel-params")"

	kernel="$(pfxcopy "$1/kernel")"
	initrd="$(pfxcopy "$1/initrd")"
	dtb="$(pfxcopy "$1/dtbs/$DTB")"

	if [ "$2" == "default" ]; then
		echo "default=$label"
	fi

	printf "%s='%s initrd=%s dtb=%s init=%s %s'\n" \
		"$label" "$kernel" "$initrd" "$dtb" "$init" "$params"
}

exec >"/boot/kboot.conf"

addEntry "$1" "default"
for i in /nix/var/nix/profiles/system-*-link; do
	addEntry "$i" "$(sed 's|system-||; s|-link||' < <(basename "$i"))"
done

rsync -a --delete "$tmp/" "$BOOT/$DEST/"
