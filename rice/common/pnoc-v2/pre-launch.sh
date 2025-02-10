#!/usr/bin/env bash
set -eEuo pipefail

nam="$1"

# find next available container ID
# 10.42.0.1 (pnoc0) + 65533 = 10.42.255.254 = highest non-broadcast
for i in {1..65533}; do
	cid="pnoc$i"
	if ip netns add "$cid" 2>/dev/null; then break; else true; fi
done

# create container registration
mkdir -p /run/pnoc/netns
ln -sfT "/run/netns/$cid" "/run/pnoc/netns/$nam"

# create ethernet bond
ip link add "$cid" up master pnoc0 type veth peer eth0 netns "$cid"
ip netns exec "$cid" ip link set eth0 up

# networkctl should now create the io.systemd.nat tables

# local IP
ipv4="$(ipadd "10.42.0.1" "$i")"
ipv6="$(ipadd "fd42::1  " "$i")"
ip netns exec "$cid" ip addr add "$ipv4/16" dev eth0
ip netns exec "$cid" ip addr add "$ipv6/80" dev eth0

# host resolution
cat <<-EOF >"/run/pnoc/hosts/$nam"
	$ipv4 $nam
	$ipv6 $nam
EOF

# outbound route
ip netns exec "$cid" ip route add default via 10.42.0.1 dev eth0
ip netns exec "$cid" ip route add default via fd42::1 dev eth0

# port forward
ports="/etc/pnoc/ports/$nam"
if [ -e "$ports" ]; then
	while true; do
		if nft list tables | grep -q io.systemd.nat; then break; fi
		sleep 1
	done

	while read -r ipv typ src dst; do
		case "$ipv" in
		4)
			tbl=ip
			ipa="$ipv4"
			;;
		6)
			tbl=ip6
			ipa="$ipv6"
			;;
		*)
			echo "port forward: invalid IP type '$ipv'!" >&2
			continue
			;;
		esac

		nft delete element "$tbl" io.systemd.nat map_port_ipport "{ $typ . $src }" 2>/dev/null || true
		nft add element "$tbl" io.systemd.nat map_port_ipport "{ $typ . $src : $ipa . $dst }"
	done <"$ports"
fi

# reset root & runtime directory
for i in rootd runtd; do
	dir="/run/pnoc/$i/$nam"
	rm -rf "$dir"
	mkdir -p "$dir"
	chmod 0755 "$dir"
done

# create data directory
if [ -e "/etc/pnoc/datadir/$nam" ]; then
	dir="/var/lib/pnoc/$nam"
	mkdir -p "$dir"
	chmod 0700 "$dir"
fi
