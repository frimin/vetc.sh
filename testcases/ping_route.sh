#!/usr/bin/env bash

BIN="${BIN:?}"

cleanup () {
    echo "Try Cleanup"
    $BIN down
    return 0
}

trap cleanup EXIT

cleanup

# Get host default route ip
default_route=$(/sbin/ip route | awk '/default/ { print $3 }' | head -n 1)

"$SHELL" "$BIN" up

for ((i=0;i<4;i++)); do
    if ! $SHELL $BIN exec ping -c 1 $default_route; then
        echo "Network unreachable"
        exit 255
    fi
done

