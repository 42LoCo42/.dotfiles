#!/usr/bin/env bash
set -u

nam="$1"
cid="$(basename "$(readlink "/run/pnoc/netns/$nam")")"
if [ -z "$cid" ]; then
	echo "No such container '$nam'!" >&2
	exit
fi

# remove container registration
rm -f "/run/pnoc/netns/$nam" "/run/pnoc/hosts/$nam"
ip netns del "$cid"

# reset port forward
ports="/etc/pnoc/ports/$nam"
if [ -e "$ports" ]; then
	while read -r ipv typ src _; do
		case "$ipv" in
		4) tbl=ip ;;
		6) tbl=ip6 ;;
		*)
			echo "port forward: invalid IP type '$ipv'!" >&2
			continue
			;;
		esac

		nft delete element "$tbl" io.systemd.nat map_port_ipport "{ $typ . $src }" 2>/dev/null
	done <"$ports"
fi

# reset root & runtime directory
for i in rootd runtd; do
	dir="/run/pnoc/$i/$nam"
	rm -rf "$dir"
done
