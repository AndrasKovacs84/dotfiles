#!/bin/bash

SESSION_FILE="${HOME}/.cache/hypr-session.json"
clients=$(hyprctl clients -j)
saved_windows=()

echo "[*] Saving session to $SESSION_FILE..."

while read -r entry; do
  pid=$(echo "$entry" | jq -r '.pid')
  class=$(echo "$entry" | jq -r '.class')
  title=$(echo "$entry" | jq -r '.title')
  workspace=$(echo "$entry" | jq -r '.workspace.id')
  floating=$(echo "$entry" | jq -r '.floating')

  # Extract x, y from .at[] array, and width/height from .size
  x=$(echo "$entry" | jq -r '.at[0]')
  y=$(echo "$entry" | jq -r '.at[1]')
  width=$(echo "$entry" | jq -r '.size[0]')
  height=$(echo "$entry" | jq -r '.size[1]')

  if [[ -f "/proc/$pid/cmdline" ]]; then
    cmdline=$(tr '\0' ' ' < "/proc/$pid/cmdline")
  else
    cmdline=""
  fi

  saved_windows+=("$(jq -n \
    --arg class "$class" \
    --arg title "$title" \
    --argjson workspace "$workspace" \
    --argjson floating "$floating" \
    --argjson x "$x" \
    --argjson y "$y" \
    --argjson width "$width" \
    --argjson height "$height" \
    --arg cmdline "$cmdline" \
    '{
      class: $class,
      title: $title,
      workspace: $workspace,
      floating: $floating,
      geometry: {
        x: $x,
        y: $y,
        width: $width,
        height: $height
      },
      cmdline: $cmdline
    }')"
  )
done < <(echo "$clients" | jq -c '.[]')

jq -n --arg time "$(date -Iseconds)" \
      --argjson windows "$(printf '%s\n' "${saved_windows[@]}" | jq -s '.')" \
      '{saved_at: $time, windows: $windows}' > "$SESSION_FILE"

count=$(jq '.windows | length' "$SESSION_FILE")
echo "[✓] Session saved: $count window(s)."
