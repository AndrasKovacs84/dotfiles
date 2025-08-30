#!/bin/bash

dry_run=false
action=""

for arg in "$@"; do
  case "$arg" in
    --dry-run)
      dry_run=true
      ;;
    --shutdown)
      action="poweroff"
      ;;
    --reboot)
      action="reboot"
      ;;
    *)
      echo "Usage: $0 [--shutdown|--reboot] [--dry-run]"
      exit 1
      ;;
  esac
done

if [[ -z "$action" ]]; then
  echo "[!] You must specify either --shutdown or --reboot"
  exit 1
fi

# Collect all window addresses
window_addresses=$(hyprctl clients -j | jq -r '.[].address')

# Loop through each window and attempt graceful close
for address in $window_addresses; do
    echo "Attempting to close window at address: $address"
    if [[ "$1" != "--dry-run" ]]; then
        hyprctl dispatch focuswindow address:$address
        sleep 0.2
        hyprctl dispatch closewindow
    else
        echo "[dry-run] Would close: $address"
    fi
    sleep 0.5  # allow app time to respond
done

# Check immediately if all windows have closed
remaining=$(hyprctl clients -j | jq -r '.[].class')

if [[ -z "$remaining" ]]; then
    echo "[✓] All windows closed immediately."
else
    echo "[*] Some windows still open, waiting briefly..."
    sleep 3

    # Re-check after wait
    remaining=$(hyprctl clients -j | jq -r '.[].class')
    if [[ -n "$remaining" ]]; then
        echo "[!] Some windows are still open:"
        echo "$remaining"
        exit 1
    fi
    echo "[✓] All windows closed after wait."
fi

# Proceed to shutdown or dry-run
if $dry_run; then
    echo "[dry-run] Would now execute: systemctl $action"
else
    echo "[*] Executing: systemctl $action"
    systemctl "$action"
fi
