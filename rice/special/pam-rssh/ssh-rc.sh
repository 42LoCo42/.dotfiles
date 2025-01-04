#!/usr/bin/env bash
link="$HOME/.ssh/auth"
if [ ! -S "$link" ] && [ -S "$SSH_AUTH_SOCK" ]; then
	ln -sf "$SSH_AUTH_SOCK" "$link"
fi
