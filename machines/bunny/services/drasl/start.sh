#!/usr/bin/env bash
envsubst <"$1" >/tmp/config.toml
exec drasl --config /tmp/config.toml
