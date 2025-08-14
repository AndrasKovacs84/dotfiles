#!/usr/bin/env python3

import json
import subprocess

try:
    status = subprocess.check_output(["playerctl", "status"], stderr=subprocess.DEVNULL).decode().strip()
    if status in ["Playing", "Paused"]:
        artist = subprocess.check_output(["playerctl", "metadata", "artist"], stderr=subprocess.DEVNULL).decode().strip()
        title = subprocess.check_output(["playerctl", "metadata", "title"], stderr=subprocess.DEVNULL).decode().strip()
        player = subprocess.check_output(["playerctl", "metadata", "xesam:url"], stderr=subprocess.DEVNULL).decode().strip()
        print(json.dumps({
            "text": f"{artist} - {title}",
            "tooltip": status,
            "class": "spotify" if "spotify" in player else "default"
        }))
    else:
        print(json.dumps({"text": "", "tooltip": "Not Playing", "class": ""}))
except Exception:
    print(json.dumps({"text": "", "tooltip": "No player", "class": ""}))
