#!/usr/bin/env bash
set -eEuo pipefail

datadir="/data/db"

if [ ! -d "$datadir" ]; then
	mkdir -p "$datadir"
	cd "$datadir"
	touch args
	mariadb-install-db --datadir "$datadir" --skip-test-db
fi

mapfile -t args <"$datadir/args"
exec mariadbd --datadir "$datadir" --socket "$datadir/mysql.sock" "${args[@]}"
