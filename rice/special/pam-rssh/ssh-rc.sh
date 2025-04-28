#!/usr/bin/env bash
link="$HOME/.ssh/auth"

connected() {
	test -S "$1" && @nc@ -zU "$1"
}

if (! connected "$link") && connected "$SSH_AUTH_SOCK"; then
	ln -sf "$SSH_AUTH_SOCK" "$link"
fi
