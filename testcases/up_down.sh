#!/usr/bin/env bash

BIN="${BIN:?}"

"$SHELL" "$BIN" up || exit 255
"$SHELL" "$BIN" down || exit 255
