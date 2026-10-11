#!/usr/bin/env bash
# Wallpaper effects with ImageMagick, applied through Caelestia

CAELESTIA=/home/patrik/.local/bin/caelestia
STATE_DIR="$HOME/.config/hypr/wallpaper_effects"
wallpaper_current="$STATE_DIR/.wallpaper_current"
wallpaper_output="$STATE_DIR/.wallpaper_modified"
rofi_theme="$HOME/.config/rofi/config-wallpaper-effect.rasi"
mkdir -p "$STATE_DIR"

# Effects and their ImageMagick arguments
declare -A effects=(
    ["Black & White"]="-colorspace gray -sigmoidal-contrast 10,40%"
    ["Blurred"]="-blur 0x10"
    ["Charcoal"]="-charcoal 0x5"
    ["Edge Detect"]="-edge 1"
    ["Emboss"]="-emboss 0x5"
    ["Frame Raised"]="+raise 150"
    ["Frame Sunk"]="-raise 150"
    ["Negate"]="-negate"
    ["Oil Paint"]="-paint 4"
    ["Posterize"]="-posterize 4"
    ["Polaroid"]="-polaroid 0"
    ["Sepia Tone"]="-sepia-tone 65%"
    ["Solarize"]="-solarize 80%"
    ["Sharpen"]="-sharpen 0x5"
    ["Vignette"]="-vignette 0x3"
    ["Vignette-black"]="-background black -vignette 0x3"
    ["Zoomed"]="-gravity Center -extent 1:1"
)

# Pressing the key again closes the menu
if pidof rofi >/dev/null; then
    pkill rofi
    exit 0
fi

# The wallpaper Caelestia is showing right now is the source for every effect
src=$("$CAELESTIA" shell wallpaper get 2>/dev/null)
if [[ -z "$src" || ! -f "$src" ]]; then
    notify-send "Wallpaper effects" "Could not read the current wallpaper"
    exit 1
fi
cp "$src" "$wallpaper_current"

choice=$({
    echo "No Effects"
    for e in "${!effects[@]}"; do echo "$e"; done | LC_COLLATE=C sort
} | rofi -dmenu -i -config "$rofi_theme")

case "$choice" in
    "")
        exit 0
        ;;
    "No Effects")
        "$CAELESTIA" wallpaper -f "$wallpaper_current"
        ;;
    *)
        if [[ -z "${effects[$choice]+x}" ]]; then
            notify-send "Wallpaper effects" "Effect '$choice' not recognized"
            exit 1
        fi
        # Unquoted on purpose: each argument must split into its own word
        magick "$wallpaper_current" ${effects[$choice]} "$wallpaper_output" &&
            "$CAELESTIA" wallpaper -f "$wallpaper_output"
        ;;
esac
