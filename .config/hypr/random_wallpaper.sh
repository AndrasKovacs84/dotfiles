#!/bin/bash

WALLPAPERS="$HOME/Képek/Wallpapers/32_9"
TRANSITIONS=("wipe" "grow" "outer" "inner" "any")
DURATIONS=(0.5 0.7 1 1.2)

# Pick a random wallpaper
wallpaper=$(find "$WALLPAPERS" -type f | shuf -n 1)

# Pick random transition and duration
transition=$(shuf -n 1 -e "${TRANSITIONS[@]}")
duration=$(shuf -n 1 -e "${DURATIONS[@]}")

# Apply with swww
swww img "$wallpaper" --transition-type "$transition" --transition-duration "$duration"
