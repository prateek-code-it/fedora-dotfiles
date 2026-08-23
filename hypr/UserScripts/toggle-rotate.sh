#!/usr/bin/env bash

SCRIPT_NAME="auto-rotate.sh"
SCRIPT_PATH="$HOME/.config/hypr/UserScripts/auto-rotate.sh"
MONITOR="eDP-1"
TOUCH_DEVICE="wacom-hid-4998-finger"
PEN_DEVICE="wacom-hid-4998-pen"

if pgrep -f "$SCRIPT_NAME" > /dev/null; then
    pkill -f "$SCRIPT_NAME"
    pkill -f "monitor-sensor"

    # Reset screen & touch back to normal orientation
    hyprctl keyword monitor "$MONITOR,preferred,auto,1,transform,0" > /dev/null 2>&1
    hyprctl keyword device["$TOUCH_DEVICE"]:transform 0 > /dev/null 2>&1
    hyprctl keyword device["$PEN_DEVICE"]:transform 0 > /dev/null 2>&1

    notify-send -u low -i preferences-desktop-display "Auto-Rotation" "Disabled (Reset to Landscape)"
else
    nohup "$SCRIPT_PATH" > /dev/null 2>&1 &
    notify-send -u low -i preferences-desktop-display "Auto-Rotation" "Enabled"
fi

