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

check_remaining_clients() {
    local timeout=$1
    local initial=$(hyprctl clients -j)
    local remaining=$(echo "$initial" | jq -r '.[].class')

    if [[ -z "$remaining" ]]; then
        return 0
    fi

    if [[ -n "$timeout" ]]; then
        sleep "$timeout"
        initial=$(hyprctl clients -j)
    fi
    echo "$initial"
    return 0
}

# Collect all window addresses
window_addresses=$(hyprctl clients -j | jq -r '.[].address')

# Loop through each window and attempt graceful close
for address in $window_addresses; do
    echo "Attempting to close window at address: $address"
    if ! $dry_run; then
        hyprctl dispatch focuswindow address:$address
        sleep 0.2
        hyprctl dispatch closewindow
    else
        echo "[dry-run] Would close: $address"
    fi
    sleep 0.5  # allow app time to respond
done

# Check immediately if all windows have closed
remaining_clients=$(check_remaining_clients 3)

if [[ -z "$remaining_clients" ]]; then 
  echo "[✓] All windows closed immediately."
else
  echo "[*] Some windows still open"
  window_list=$(echo "$remaining_clients" | jq -r '.[] | "\(.class) - \(.title)"' | sort | uniq)
  message="The following windows are still open:\n\n$window_list\n\nForce close them?"
  kdialog --yesno "$message"
  if [[ $? -eq 0 ]]; then
    if $dry_run; then
      echo "[dry-run] Would force close: $window_list"
    else
      echo "$remaining_clients" | jq -r '.[].pid' | xargs -r kill -9
      sleep 1
    fi
  else
    echo "[!] Shutdown aborted by user."
    exit 1
  fi

  remaining_clients=$(check_remaining_clients 3)
  if [[ -z "$remaining_clients" ]]; then
    echo "[✓] All windows closed after wait."
  else
    final_window_list=$(echo "$remaining_clients" | jq -r '.[] | "\(.class) - \(.title)"' | sort | uniq)
    echo "[✗] Some windows could not be closed:"
    echo "$final_window_list"

    kdialog --error "The following windows could not be closed:\n\n$final_window_list\n\nPlease close them manually." --title "Shutdown Aborted"
    exit 1
  fi

fi

# Proceed to shutdown or dry-run
if $dry_run; then
    echo "[dry-run] Would now execute: systemctl $action"
else
    echo "[*] Executing: systemctl $action"
    systemctl "$action"
fi
