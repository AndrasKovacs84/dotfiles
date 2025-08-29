#!/bin/bash

export PATH="$HOME/.local/bin:$PATH"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export HOME="$HOME"

WALLPAPERS="$HOME/Képek/Wallpapers/32_9"
DURATIONS=(0.5 0.7 1 1.2)

# Start swww-daemon if not running
pgrep -x swww-daemon >/dev/null || swww-daemon &

# Wait for swww to be ready
until swww query >/dev/null 2>&1; do sleep 0.1; done

# Pick a random wallpaper
wallpaper=$(find "$WALLPAPERS" -type f | shuf -n 1)

# Apply pywal colors
wal -q -i "$wallpaper"

# Set the wallpaper
duration=$(shuf -n 1 -e "${DURATIONS[@]}")
swww img "$wallpaper" --transition-type "random" --transition-duration "$duration"

# Start Waybar (kill existing just in case)
pkill waybar
sleep 1
waybar &
