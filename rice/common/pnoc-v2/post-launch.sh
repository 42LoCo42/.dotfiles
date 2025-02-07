#!/usr/bin/env bash
set -eEuo pipefail

nam="$1"
uid="$(id -u "pnoc-$nam")"
gid="$(id -g "pnoc-$nam")"

# chown data directory
if [ -e "/etc/pnoc/datadir/$nam" ]; then
	dir="/var/lib/pnoc/$nam"
	chown -R "$uid:$gid" "$dir"
fi

# set up /etc
dir="/run/pnoc/rootd/$nam/etc"
mkdir -p "$dir"

cat <<-EOF >"$dir/passwd"
	root:x:0:0:root:/root:/bin/sh
	$nam:x:$uid:$gid:$nam:/:/bin/sh
EOF

cat <<-EOF >"$dir/group"
	root:x:0:
	$nam:x:$gid:
EOF
