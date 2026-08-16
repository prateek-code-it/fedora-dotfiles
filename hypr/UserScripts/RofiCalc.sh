#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
# /* Calculator (using qalculate) and rofi */
# /* Submitted by: https://github.com/JosephArmas */

# /* ---- 💫 Enhanced Qalculate + Rofi Calculator 💫 ---- */

rofi_theme="${HOME}/.config/rofi/config-calc.rasi"
history_file="/tmp/rofi_qalc_history_$$"

# Clean up temp history file on exit
trap 'rm -f "$history_file"' EXIT

# Toggle behavior: if rofi is already open, pressing your hotkey closes it
if pgrep -x "rofi" >/dev/null; then
    pkill -x "rofi"
    exit 0
fi

# Dependency check
for cmd in rofi qalc wl-copy; do
    if ! command -v "$cmd" &>/dev/null; then
        notify-send -u critical "Calculator Error" "Missing required command: $cmd"
        exit 1
    fi
done

# Build rofi options (uses theme if present, otherwise falls back gracefully)
rofi_args=(-dmenu -i -p "󰪚 Calc")
if [ -f "$rofi_theme" ]; then
    rofi_args+=(-config "$rofi_theme")
fi

mesg="💡 Type an expression (e.g., 25*4, 50 USD to EUR, sqrt(256))"
touch "$history_file"

while true; do
    # Display calculation history inside rofi (most recent on top)
    user_input=$(
        tac "$history_file" 2>/dev/null | rofi "${rofi_args[@]}" -mesg "$mesg"
    )
    rofi_exit=$?

    # Exit if user pressed Escape / cancelled or provided empty input
    if [ $rofi_exit -ne 0 ] || [ -z "$user_input" ]; then
        exit 0
    fi

    # If user selected an item from history (format: "expr = result"), copy just the result
    if [[ "$user_input" == *" = "* ]]; then
        calc_result="${user_input##* = }"
        echo -n "$calc_result" | wl-copy
        mesg="📋 Copied '$calc_result' to clipboard"
        continue
    fi

    # Evaluate expression with qalc (-t gives concise output)
    calc_result=$(qalc -t "$user_input" 2>&1)

    if [ -n "$calc_result" ] && [[ "$calc_result" != *"error"* && "$calc_result" != *"warning"* ]]; then
        # Copy cleanly to Wayland clipboard without trailing newlines
        echo -n "$calc_result" | wl-copy

        # Update display message and append to session history
        mesg="✨ $user_input = $calc_result (Copied)"
        echo "$user_input = $calc_result" >> "$history_file"
    else
        mesg="❌ Invalid Expression: $user_input"
    fi
done
