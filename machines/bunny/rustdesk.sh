#!/usr/bin/env bash
pubkey="@pubkey@"

run_hbbr() {
	echo "Starting hbbr..."
	hbbr -k "$pubkey" & hbbr="$!"
}

run_hbbs() {
	echo "Starting hbbs..."
	hbbs -k "$pubkey" -r "localhost" & hbbs="$!"
}

run_hbbr
run_hbbs

while true; do
	wait -np child
	if ((child == hbbr)); then
		run_hbbr
	elif ((child == hbbs)); then
		run_hbbs
	fi
done
