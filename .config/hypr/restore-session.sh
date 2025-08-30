
#!/bin/bash

SESSION_FILE="${HOME}/.cache/hypr-session.json"

if [[ ! -f "$SESSION_FILE" ]]; then
  echo "[!] No saved session found at $SESSION_FILE"
  exit 1
fi

echo "[*] Restoring session from $SESSION_FILE..."

windows=$(jq -c '.windows[]' "$SESSION_FILE")

while IFS= read -r window; do
  flatpak_id=$(echo "$window" | jq -r '.flatpak_id')
  cmdline=$(echo "$window" | jq -r '.cmdline' | xargs)

  if [[ -n "$flatpak_id" && "$flatpak_id" != "null" ]]; then
    echo "[*] Launching Flatpak: $flatpak_id"
    flatpak run "$flatpak_id" & disown
  elif [[ -n "$cmdline" && "$cmdline" != "null" ]]; then
    echo "[*] Launching: $cmdline"
    eval "$cmdline" & disown
  else
    echo "[!] Skipping entry, no launch info available"
  fi
done <<< "$windows"

echo "[✓] Session restore complete."
