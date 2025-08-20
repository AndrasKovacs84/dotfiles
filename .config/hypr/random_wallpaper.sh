#!/bin/bash

# Ensure pip-installed tools are accessible
export PATH="$HOME/.local/bin:$PATH"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"  # just in case

# Pywal needs this to find HOME in non-interactive shells
export HOME="$HOME"

# Your wallpaper logic...

WALLPAPERS="$HOME/Képek/Wallpapers/32_9"
TRANSITIONS=("wipe" "grow" "outer" "inner" "any")
DURATIONS=(0.5 0.7 1 1.2)

# Pick a random wallpaper
wallpaper=$(find "$WALLPAPERS" -type f | shuf -n 1)

wal -q -i "$wallpaper"

# Pick random transition and duration
transition=$(shuf -n 1 -e "${TRANSITIONS[@]}")
duration=$(shuf -n 1 -e "${DURATIONS[@]}")

# Apply with swww
swww img "$wallpaper" --transition-type "$transition" --transition-duration "$duration"
