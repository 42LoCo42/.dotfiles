#!/bin/sh
sensors | grep -F "Tctl" | awk '{gsub("+", "", $2); print $2}'
