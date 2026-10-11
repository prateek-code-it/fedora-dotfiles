#!/usr/bin/env bash
# Change wallpaper randomly every 30 minutes using Caelestia
INTERVAL=1800
while true; do
  /home/patrik/.local/bin/caelestia wallpaper -r
  sleep $INTERVAL
done
