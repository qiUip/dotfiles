#!/bin/zsh
setopt nullglob

# Config paths
TERMINAL_APPS="$HOME/.config/choose-launcher/terminal"
BACKGROUND_APPS="$HOME/.config/choose-launcher/background"
mkdir -p "$(dirname "$TERMINAL_APPS")"

# Collect GUI apps
GUI_APPS=()
GUI_DIRS=(/Applications /System/Applications /System/Library/CoreServices ~/Applications)
for dir in $GUI_DIRS; do
  [[ -d "$dir" ]] || continue
  GUI_APPS+=("${(@f)$(find "$dir" -maxdepth 1 -type d -name "*.app" | sed 's/.*\///; s/\.app$//')}")
done

# Collect CLI apps from $PATH
CLI_APPS=()
for dir in ${(s/:/)PATH}; do
  [[ -d "$dir" ]] || continue
  for file in "$dir"/*; do
    [[ -f "$file" && -x "$file" ]] && CLI_APPS+=("${file##*/}")
  done
done

# Collect aliases
ALIASES=("${(@f)$(alias | sed -nE 's/^([^=]+)=.*/\1/p')}")

# Combine all app names and remove duplicates (case-insensitive)
ALL_APPS=("${(u)GUI_APPS[@]}" "${(u)CLI_APPS[@]}" "${(u)ALIASES[@]}")
ALL_APPS=("${(ou)ALL_APPS[@]}")

typeset -A seen
unique_apps=()

for app in "${ALL_APPS[@]}"; do
  lc_app=${app:l}   # lowercase the app name
  if [[ -z ${seen[$lc_app]} ]]; then
    unique_apps+=("$app")
    seen[$lc_app]=1
  fi
done

ALL_APPS=("${unique_apps[@]}")

# SELECTED=$(printf "%s\n" "${ALL_APPS[@]}" | choose -az -s 20 -w 20 -b 5E81AC -c A3BE8C -f "Hack Nerd Font Mono")
SELECTED=$(printf "%s\n" "${ALL_APPS[@]}" | dmenu --bg-color 2E3440 --text-color ECEFF4 --highlight-color 81A1C1 -r 6 -s -i --font "Hack Nerd Font Mono")

[[ -z "$SELECTED" ]] && exit 0

# Function to resolve symlinks to real target
resolve_target() {
  local path=$1
  while [[ -L "$path" ]]; do
    local dir=${path:h}
    local link
    link=$(command /bin/ls -l "$path" | /opt/homebrew/bin/awk '{print $NF}')
    [[ "$link" == /* ]] && path="$link" || path="$dir/$link"
  done
  echo "$path"
}

app_path=""

# Search GUI apps folders for selected app (append .app)
for dir in $GUI_DIRS; do
  local candidate="$dir/$SELECTED.app"
  if [[ -d "$candidate" ]]; then
    app_path="$candidate"
    break
  fi
done

# If not GUI app found, search in PATH dirs for executable or alias
if [[ -z "$app_path" ]]; then
  for dir in ${(s/:/)PATH}; do
    local candidate="$dir/$SELECTED"
    if [[ -x "$candidate" && ! -d "$candidate" ]]; then
      app_path="$candidate"
      break
    fi
  done
fi

# Resolve symlink of app_path if needed
if [[ -n "$app_path" ]]; then
  app_path=$(resolve_target "$app_path")
fi

# Helper functions
is_terminal_app() grep -qxF "$1" "$TERMINAL_APPS" 2>/dev/null
is_background_app() grep -qxF "$1" "$BACKGROUND_APPS" 2>/dev/null

# Launch logic
if is_terminal_app "$SELECTED"; then
  kitty --single-instance -e "$app_path" &
elif is_background_app "$SELECTED"; then
  if [[ "$app_path" == *.app ]]; then
    open "$app_path"
  else
    "$app_path" &
  fi
else
  # METHOD=$(printf "terminal\nbackground" | choose -az -s 20 -w 20 -b 5E81AC -c A3BE8C -f "Hack Nerd Font Mono")
  METHOD=$(printf "terminal\nbackground" | dmenu --bg-color 2E3440 --text-color ECEFF4 --highlight-color 81A1C1 -r 3 -s -i --font "Hack Nerd Font Mono")
  [[ -z "$METHOD" ]] && exit 0

  if [[ "$METHOD" == "terminal" ]]; then
    echo "$SELECTED" >> "$TERMINAL_APPS"
    kitty --single-instance -e "$app_path" &
  else
    echo "$SELECTED" >> "$BACKGROUND_APPS"
    if [[ "$app_path" == *.app ]]; then
      open "$app_path"
    else
      "$app_path" &
    fi
  fi
fi

