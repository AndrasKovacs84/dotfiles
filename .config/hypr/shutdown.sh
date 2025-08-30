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

log() {
  echo "$1"
  logger -t graceful-shutdown "$1"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/save-session.sh"

log "[+] Graceful shutdown initiated with action: $action (dry-run: $dry_run)"

# Collect all window addresses
window_addresses=$(hyprctl clients -j | jq -r '.[].address')

# Loop through each window and attempt graceful close
for address in $window_addresses; do
    log "[*] Attempting to close window at address: $address"
    if ! $dry_run; then
        hyprctl dispatch closewindow address:$address
    else
        log "[dry-run] Would close: $address"
    fi
    sleep 0.5  # allow app time to respond
done

remaining_clients=$(check_remaining_clients 3)

if [[ -z "$remaining_clients" ]]; then 
  log "[✓] All windows closed immediately."
else
  log "[*] Some windows still open"
  window_list=$(echo "$remaining_clients" | jq -r '.[] | "\(.class) - \(.title)"' | sort | uniq)
  message="The following windows are still open:\n\n$window_list\n\nForce close them?"
  kdialog --yesno "$message" --title "Force Close Remaining Apps"
  if [[ $? -eq 0 ]]; then
    if $dry_run; then
      log "[dry-run] Would force close: $window_list"
    else
      echo "$remaining_clients" | jq -r '.[].pid' | xargs -r kill -9
      sleep 1
    fi
  else
    log "[!] Shutdown aborted by user."
    exit 1
  fi

  remaining_clients=$(check_remaining_clients 3)
  if [[ -z "$remaining_clients" ]]; then
    log "[✓] All windows closed after wait."
  else
    final_window_list=$(echo "$remaining_clients" | jq -r '.[] | "\(.class) - \(.title)"' | sort | uniq)
    log "[✗] Some windows could not be closed:"
    while IFS= read -r line; do
      log "[!] Still open: $line"
    done <<< "$final_window_list"

    kdialog --error "The following windows could not be closed:\n\n$final_window_list\n\nPlease close them manually." --title "Shutdown Aborted"
    exit 1
  fi
fi

# Proceed to shutdown or dry-run
if $dry_run; then
    log "[dry-run] Would now execute: systemctl $action"
else
    log "[*] Executing: systemctl $action"
    systemctl "$action"
fi
