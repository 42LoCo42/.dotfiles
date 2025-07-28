#!/usr/bin/env bash

mkdir -p /data/cache
mkdir -p /data/work/pics
for i in Artist AlbumArtist; do
	ln -sfT "/music/ARTIST_COVERS" "/data/work/pics/$i"
done

exec mympd \
	--cachedir /data/cache \
	--workdir /data/work
