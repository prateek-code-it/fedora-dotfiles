#!/usr/bin/env bash

updates=$(dnf check-update 2>/dev/null | awk '
    /^[A-Za-z0-9_.+-]+[[:space:]]+[0-9]/ {
        print $1
    }
')

num_updates=$(printf '%s\n' "$updates" | sed '/^$/d' | wc -l)

if (( num_updates == 0 )); then
    tooltip="System is up to date"
else
    tooltip=$(printf '%s\n' "$updates" | head -n 50 | paste -sd '\n' -)

    if (( num_updates > 50 )); then
        other_amount=$((num_updates - 50))
        tooltip="${tooltip}\nAnd ${other_amount} more..."
    fi
fi

printf '{"text":"%s","tooltip":"%s"}\n' "$num_updates" "$tooltip"
