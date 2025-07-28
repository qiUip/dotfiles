#!/usr/bin/env sh

# WINDOW_INFO=$(yabai -m query --windows \
#   | jq -r '.[] | select(.app != "Finder") | "\(.id): \(.app) — \(.title)"' \
#   | choose -azdS -s 20 -w 20 -b 5E81AC -c A3BE8C -f "Hack Nerd Font Mono")

WINDOW_INFO=$(yabai -m query --windows \
  | jq -r '.[]
  | select(.app != "Finder" and (.title | length > 0))
  | "\(.id): \(.app) — \(.title)"' \
  | choose -azdS -s 20 -w 20 -b 5E81AC -c A3BE8C -f "Hack Nerd Font Mono")

if [ -n "$WINDOW_INFO" ]; then
  WIN_ID=$(echo "$WINDOW_INFO" | cut -d ':' -f 1)
  CURRENT_SPACE=$(yabai -m query --spaces --space | jq -r '.index')
  yabai -m window "$WIN_ID" --space "$CURRENT_SPACE"
  yabai -m window --focus "$WIN_ID"
fi
