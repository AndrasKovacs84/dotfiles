#!/bin/bash

# Ensure pip-installed tools are accessible
export PATH="$HOME/.local/bin:$PATH"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"  # just in case

# Pywal needs this to find HOME in non-interactive shells
export HOME="$HOME"

WALLPAPERS="$HOME/Képek/Wallpapers/32_9"
DURATIONS=(0.5 0.7 1 1.2)

wallpaper=$(find "$WALLPAPERS" -type f | shuf -n 1)

wal -q -i "$wallpaper"

pkill -SIGUSR2 waybar

duration=$(shuf -n 1 -e "${DURATIONS[@]}")

swww img "$wallpaper" --transition-type "random" --transition-duration "$duration"
