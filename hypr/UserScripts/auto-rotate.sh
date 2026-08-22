#!/usr/bin/env bash

MONITOR="eDP-1"
TOUCH_DEVICE="wacom-hid-4998-finger"
PEN_DEVICE="wacom-hid-4998-pen"

# Ensure monitor is mapped to touch and pen inputs initially
hyprctl keyword device["$TOUCH_DEVICE"]:output "$MONITOR" > /dev/null 2>&1
hyprctl keyword device["$PEN_DEVICE"]:output "$MONITOR" > /dev/null 2>&1

monitor-sensor | while read -r line; do
    if [[ "$line" =~ "Accelerometer orientation changed:" ]]; then
        ORIENTATION=$(echo "$line" | awk -F': ' '{print $2}' | tr -d ' ')

        case "$ORIENTATION" in
            "normal")
                TRANSFORM=0
                ;;
            "bottom-up")
                TRANSFORM=2
                ;;
            "right-up")
                TRANSFORM=3
                ;;
            "left-up")
                TRANSFORM=1
                ;;
            *)
                continue
                ;;
        esac

        # Rotate display
        hyprctl keyword monitor "$MONITOR,preferred,auto,1,transform,$TRANSFORM" > /dev/null 2>&1

        # Rotate touch and pen inputs
        hyprctl keyword device["$TOUCH_DEVICE"]:transform "$TRANSFORM" > /dev/null 2>&1
        hyprctl keyword device["$PEN_DEVICE"]:transform "$TRANSFORM" > /dev/null 2>&1
    fi
done
