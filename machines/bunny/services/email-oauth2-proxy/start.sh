#!/usr/bin/env bash
set -eEuo pipefail

umask 0077
envsubst <"$1" >/tmp/emailproxy.config

exec emailproxy \
	--no-gui \
	--local-server-auth \
	--config-file /tmp/emailproxy.config \
	--cache-store /data/emailproxy.cache
