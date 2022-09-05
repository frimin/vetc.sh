#!/usr/bin/env bash

BIN="${BIN:?}"

vetc1 () {
    export VETC_NAME="vetc1"
    export VETC_VETH_ADDR="10.9.3.1"
    export VETC_VPEER_ADDR="10.9.3.2"
    "$SHELL" "$BIN" "$@"
}

vetc2 () {
    export VETC_NAME="vetc2"
    export VETC_VETH_ADDR="10.9.4.1"
    export VETC_VPEER_ADDR="10.9.4.2"
    "$SHELL" "$BIN" "$@"
}

cleanup () {
    echo "Try Cleanup"
    vetc1 down
    vetc2 down
}

trap cleanup EXIT

cleanup

echo "Create vetc1"
vetc1 up || exit 255
echo "Create vetc2"
vetc2 up || exit 255
