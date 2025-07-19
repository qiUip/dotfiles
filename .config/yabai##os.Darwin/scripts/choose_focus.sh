#!/usr/bin/env sh

WINDOW_INFO=$(yabai -m query --windows \
  | jq -r '.[] 
      | select(
          .app != "Finder" and
          (.title | length > 0)
        ) 
      | "\(.id): \(.app) — \(.title)"' \
  | choose -azdS -s 20 -w 12 -b 5E81AC -c A3BE8C -f "Hack Nerd Font Mono")

# WINDOW_INFO=$(yabai -m query --windows \
#   | jq -r '.[] | select(.app != "Finder") | "\(.id): \(.app) — \(.title)"' \
#   | choose)

if [ -n "$WINDOW_INFO" ]; then
  WIN_ID=$(echo "$WINDOW_INFO" | cut -d ':' -f 1)

  # Focus the window
  yabai -m window --focus "$WIN_ID"
fi
