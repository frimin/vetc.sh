#!/usr/bin/env bash

BIN="${BIN:?}"

TEMP_FILE='./dltest'

# Disable http proxy
unset http_proxy
unset https_proxy

cleanup () {
    echo "Try Cleanup"
    [[ -a "$TEMP_FILE" ]] && /usr/bin/rm -f "$TEMP_FILE"
    for pid in $(jobs -p); do
        echo "kill $pid"
        kill -s 9 $pid
        #pkill -TERM -P $pid
    done
    "$SHELL" "$BIN" down
    return 0
}

trap cleanup EXIT

cleanup

veth_addr="$("$SHELL" "$BIN" get veth_addr)"
vpeer_addr="$("$SHELL" "$BIN" get vpeer_addr)"

echo "Creat temp file: $TEMP_FILE"

dd if=/dev/zero of="$TEMP_FILE" bs=10KB count=1 oflag=dsync || exit 255

"$SHELL" "$BIN" up || exit 255
"$SHELL" "$BIN" orate 8Kbit || exit 255
# Start http server inside vpeer
"$SHELL" "$BIN" exec python3 -m http.server 30080 --bind $vpeer_addr &
# Start http server outside vpeer
python3 -m http.server 30081 --bind $veth_addr &

sleep 1

inside_dl_url="http://$vpeer_addr:30080/$(basename $TEMP_FILE)"
outside_dl_url="http://$veth_addr:30081/$(basename $TEMP_FILE)"

echo "Download: veth ($veth_addr) -> vpeer ($vpeer_addr) $inside_dl_url"

start_t=$(date +%s)
curl -o /dev/null $inside_dl_url || exit 255
end_t=$(date +%s)

echo "Download time: $((end_t-start_t)) "

[[ $((end_t-start_t)) -gt 3 ]] || exit 255

echo "Download: vpeer ($vpeer_addr) -> veth ($veth_addr) $outside_dl_url"

start_t=$(date +%s)
"$SHELL" "$BIN" exec curl -o /dev/null $outside_dl_url || exit 255
end_t=$(date +%s)

echo "Download time: $((end_t-start_t)) "

[[ $((end_t-start_t)) -lt 3 ]] || exit 255

"$SHELL" "$BIN" irate 8Kbit || exit 255

echo "Download: veth ($veth_addr) -> vpeer ($vpeer_addr) $inside_dl_url"

start_t=$(date +%s)
curl -o /dev/null $inside_dl_url || exit 255
end_t=$(date +%s)

echo "Download time: $((end_t-start_t)) "

[[ $((end_t-start_t)) -lt 3 ]] || exit 255

echo "Download: vpeer ($vpeer_addr) -> veth ($veth_addr) $outside_dl_url"

start_t=$(date +%s)
"$SHELL" "$BIN" exec curl -o /dev/null $outside_dl_url || exit 255
end_t=$(date +%s)

echo "Download time: $((end_t-start_t)) "

[[ $((end_t-start_t)) -gt 3 ]] || exit 255

