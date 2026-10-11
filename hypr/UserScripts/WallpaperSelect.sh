#!/usr/bin/env bash
# SUPER+W: pick a wallpaper with Caelestia's engine, using rofi as the menu

WALL_DIR="$HOME/Pictures/Wallpapers"

# Pressing SUPER+W again closes the menu
if pidof rofi >/dev/null; then
  pkill rofi
  exit 0
fi

# Build the list from the folder itself (static images only)
list=$(find -L "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) \
  | sed "s|^$WALL_DIR/||" | sort)

if [[ -z "$list" ]]; then
  notify-send "Wallpaper" "No images found in $WALL_DIR"
  exit 1
fi

# Each entry gets its image as a thumbnail; "random" comes first
menu() {
  printf "random\x00icon\x1f%s\n" "$WALL_DIR/$(head -n1 <<< "$list")"
  while IFS= read -r name; do
    printf "%s\x00icon\x1f%s\n" "$name" "$WALL_DIR/$name"
  done <<< "$list"
}

choice=$(menu | rofi -dmenu -i -show-icons -p "Wallpaper" \
  -theme-str 'element-icon { size: 6em; }')

[[ -z "$choice" ]] && exit 0

if [[ "$choice" == "random" ]]; then
  /home/patrik/.local/bin/caelestia wallpaper -r
else
  /home/patrik/.local/bin/caelestia wallpaper -f "$WALL_DIR/$choice"
fi
