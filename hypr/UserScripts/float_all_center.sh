#!/usr/bin/env bash

# Get active workspace ID
WS_ID=$(hyprctl activeworkspace -j | jq '.id')

# Get JSON array of all clients on the active workspace
CLIENTS_JSON=$(hyprctl clients -j | jq "[.[] | select(.workspace.id == $WS_ID)]")

# Check if at least one window on this workspace is currently floating
ANY_FLOATING=$(echo "$CLIENTS_JSON" | jq '[.[] | select(.floating == true)] | length')

if [ "$ANY_FLOATING" -gt 0 ]; then
  # --- TURN OFF: Tile all windows ---
  echo "$CLIENTS_JSON" | jq -r '.[].address' | while read -r ADDR; do
    [ -n "$ADDR" ] && hyprctl dispatch settiled address:$ADDR
  done
else
  # --- TURN ON: Float, resize (~half screen), and center all windows ---
  echo "$CLIENTS_JSON" | jq -r '.[].address' | while read -r ADDR; do
    if [ -n "$ADDR" ]; then
      hyprctl dispatch setfloating address:$ADDR
      hyprctl dispatch resizewindowpixel exact 55% 60%,address:$ADDR
      hyprctl dispatch centerwindow 1 address:$ADDR
    fi
  done
fi
