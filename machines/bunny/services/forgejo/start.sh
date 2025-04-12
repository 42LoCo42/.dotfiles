#!/usr/bin/env bash
set -eEuo pipefail
environment-to-ini --config "$1" --out /tmp/config.ini
chmod 400 /tmp/config.ini
exec gitea --config /tmp/config.ini
