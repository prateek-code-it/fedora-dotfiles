#!/usr/bin/env bash

# Kill any existing dashboard instances
pkill -f "class cava-term" 2>/dev/null
pkill -f "class fetch-term" 2>/dev/null
pkill -f "class clock-term" 2>/dev/null


# Open fastfetch on  left
kitty --class fetch-term -e zsh -c "exec zsh" &
sleep 0.2

# Open visualizer on top right
kitty --class cava-term -e cava &
sleep 0.2


# Open clock on bottom right
kitty --class clock-term -e tclock  &
