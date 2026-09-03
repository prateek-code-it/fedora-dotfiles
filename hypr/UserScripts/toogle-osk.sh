#!/bin/bash

# Toggle wvkbd
if pgrep -x "wvkbd-mobintl" > /dev/null; then
    pkill -x "wvkbd-mobintl"
else
    # -L sets the height in pixels (adjust 250-350 to preference)
    # -bg sets background, -fg sets foreground if needed
    wvkbd-mobintl -L 300 &
fi
