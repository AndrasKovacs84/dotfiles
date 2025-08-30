#!/bin/bash

SESSION_FILE="${HOME}/.cache/hypr-session.json"
MAX_WAIT=10  # seconds
POLL_INTERVAL=0.2

if [[ ! -f "$SESSION_FILE" ]]; then
  echo "[!] No saved session found at $SESSION_FILE"
  exit 1
fi

echo "[*] Restoring session from $SESSION_FILE..."

windows=$(jq -c '.windows[]' "$SESSION_FILE")

declare -A pending_windows=()
declare -A seen_addresses=()

# Step 1: Launch apps
while IFS= read -r window; do
  flatpak_id=$(echo "$window" | jq -r '.flatpak_id')
  cmdline=$(echo "$window" | jq -r '.cmdline' | xargs)
  class=$(echo "$window" | jq -r '.class')
  title=$(echo "$window" | jq -r '.title')

  if [[ -n "$flatpak_id" && "$flatpak_id" != "null" ]]; then
    echo "[*] Launching Flatpak: $flatpak_id"
    flatpak run "$flatpak_id" & disown
  elif [[ -n "$cmdline" && "$cmdline" != "null" ]]; then
    echo "[*] Launching: $cmdline"
    eval "$cmdline" & disown
  else
    echo "[!] Skipping entry, no launch info"
    continue
  fi

  key="${class}__${title}"
  pending_windows["$key"]="$window"
done <<< "$windows"

# Step 2: Wait and apply session state
echo "[*] Waiting for windows to appear..."

end_time=$((SECONDS + MAX_WAIT))

while [[ ${#pending_windows[@]} -gt 0 && $SECONDS -lt $end_time ]]; do
  sleep "$POLL_INTERVAL"

  current_clients=$(hyprctl clients -j)

  # Read client info without subshell so we can unset
  while IFS= read -r client; do
    c_class=$(echo "$client" | jq -r '.class')
    c_title=$(echo "$client" | jq -r '.title')
    address=$(echo "$client" | jq -r '.address')

    [[ -n "${seen_addresses[$address]}" ]] && continue
    seen_addresses["$address"]=1

    key="${c_class}__${c_title}"
    [[ -z "${pending_windows[$key]}" ]] && continue

    win_json="${pending_windows[$key]}"
    workspace=$(echo "$win_json" | jq -r '.workspace')
    floating=$(echo "$win_json" | jq -r '.floating')

    echo "[+] Found window: $c_class \"$c_title\" → $address"
    echo "    ↪ Moving to workspace $workspace"
    hyprctl dispatch movetoworkspacesilent "$workspace,address:$address"

    if [[ "$floating" == "true" ]]; then
      echo "    ↪ Toggling to floating"
      hyprctl dispatch togglefloating "address:$address"
    fi

    unset pending_windows["$key"]
  done < <(echo "$current_clients" | jq -c '.[]')
done

# Final report
if [[ ${#pending_windows[@]} -gt 0 ]]; then
  echo "[!] Some windows didn’t show up in time:"
  for key in "${!pending_windows[@]}"; do
    echo "    - $key"
  done
fi

echo "[✓] Session restore complete."
