#!/bin/bash

# Toggle default microphone source in PipeWire
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# Read mute status and update LED
if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "\[MUTED\]"; then
    echo 1 > /sys/class/leds/hda::micmute/brightness 2>/dev/null
else
    echo 0 > /sys/class/leds/hda::micmute/brightness 2>/dev/null
fi
