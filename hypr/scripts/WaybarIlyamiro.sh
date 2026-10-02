#!/usr/bin/env bash

WAYBAR_CONFIG="$HOME/.config/waybar/ilyamiro/configs/[TOP] Custom.c"
WAYBAR_STYLE="$HOME/.config/waybar/ilyamiro/style/custom.css"

pkill -x waybar 2>/dev/null
sleep 0.2

waybar -c "$WAYBAR_CONFIG" -s "$WAYBAR_STYLE" &
