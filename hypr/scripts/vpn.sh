#!/bin/bash

# Check if WARP is currently connected using whole-word matching (-w)
if warp-cli status 2>&1 | grep -qw "Connected"; then
    warp-cli disconnect
    notify-send -u normal -i network-vpn "Cloudflare WARP" "VPN Disconnected"
else
    warp-cli connect
    notify-send -u normal -i network-vpn "Cloudflare WARP" "VPN Connected Successfully"
fi
