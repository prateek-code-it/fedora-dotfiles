#!/bin/bash

# Check if WARP is currently connected using whole-word matching (-w)
if warp-cli status 2>&1 | grep -qw "Connected"; then
    warp-cli disconnect
    /home/patrik/.local/bin/caelestia shell toaster info "Cloudflare WARP" "VPN Disconnected" network-vpn
else
    warp-cli connect
    /home/patrik/.local/bin/caelestia shell toaster success "Cloudflare WARP" "VPN Connected" network-vpn
fi
