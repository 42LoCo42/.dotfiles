#!/usr/bin/env bash
pubkey="@pubkey@"

run_hbbr() {
	echo "Starting relay server..."
	hbbr -k "$pubkey" &
	hbbr="$!"
}

run_hbbs() {
	echo "Starting signaling server..."
	hbbs -k "$pubkey" -r "localhost" &
	hbbs="$!"
}

run_api() {
	echo "Starting API server..."

	# work around hardcoded bullshit
	mkdir -p data                   # DB
	ln -sfT "@resources@" resources # web templates?

	apimain -c "@config@" &
	api="$!"
}

run_hbbr
run_hbbs
run_api

while true; do
	wait -np child
	if ((child == hbbr)); then
		run_hbbr
	elif ((child == hbbs)); then
		run_hbbs
	elif ((child == api)); then
		run_api
	fi
done
