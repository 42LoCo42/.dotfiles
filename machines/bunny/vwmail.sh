#!/usr/bin/env bash
tr -d '\r' | sed 's|=$||; s|=3D|=|g' > /data/mail
