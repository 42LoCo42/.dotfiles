#!/bin/sh
echo -n ' '
sensors | grep -F "Tctl" | awk '{gsub("+", "", $2); print $2}'
