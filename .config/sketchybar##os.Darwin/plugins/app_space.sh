#!/bin/bash

# Load global styles, colors and icons
source "$CONFIG_DIR/globalstyles.sh"

SID=$1
DEBUG=0

# Set this to the UUID of the built-in/notched display to suppress app-title
# text there while preserving the current full icon/title layout elsewhere.
# Find it with: yabai -m query --displays | jq -r '.[] | "\(.index) \(.uuid) \(.frame.w)x\(.frame.h)"'
BUILTIN_DISPLAY_UUID="${BUILTIN_DISPLAY_UUID:-37D8832A-2D66-02CA-B9F7-8F30A301B230}"

space_display_uuid() {
  local space_display
  space_display=$(yabai -m query --spaces | jq -r --argjson sid "$SID" '.[] | select(.index == $sid) | .display // empty')
  [[ -z "$space_display" ]] && return 1

  yabai -m query --displays | jq -r --argjson display "$space_display" '.[] | select(.index == $display) | .uuid // empty'
}

show_focused_app_title() {
  local display_uuid

  # If no built-in display UUID is configured, preserve current behavior.
  [[ -z "$BUILTIN_DISPLAY_UUID" ]] && return 0

  display_uuid=$(space_display_uuid)
  [[ "$display_uuid" != "$BUILTIN_DISPLAY_UUID" ]]
}

append_focused_app_title() {
  local app="$1"
  local current_app="$2"

  [[ "$app" == "$current_app" ]] && show_focused_app_title
}

create_icons() {
  QUERY=$(yabai -m query --windows --space "$SID" | jq '[.[] | select(.scratchpad == "")]')
  IFS=$'\n'
  local APPS=($(echo "$QUERY" | jq -r 'map(select((.title | length) > 0)) | .[].app' | sort -u))
  local CURRENT_APP=$(echo "$QUERY" | jq -r 'map(select((.title | length) > 0)) | .[] | select(.["has-focus"] == true) | .app')
  local LABEL ICON

  # Get space label for this index
  SPACE_LABEL=$(yabai -m query --spaces | jq -r --argjson sid "$SID" '.[] | select(.index == $sid) | .label // ""')
  [[ -z "$SPACE_LABEL" ]] && SPACE_LABEL="$SID"

  debug $FUNCNAME

  for APP in "${APPS[@]}"; do
    local TITLE=$(echo "$QUERY" | jq -r 'map(select((.title | length) > 0 and .app == "'"$APP"'")) | .[0].title')
    ICON=$("$HOME/.config/sketchybar/plugins/app_icon.sh" "$APP" "$TITLE")

    # Append app name only for the focused app, except on the built-in/notched display.
    append_focused_app_title "$APP" "$CURRENT_APP" && ICON+=" $APP"

    LABEL+="$ICON"
    [[ ${#APPS[@]} -gt 1 ]] && LABEL+=" "
  done
  unset IFS

  sketchybar --set "$NAME" label="$SPACE_LABEL $LABEL"
}

update_icons() {
  if [ "$SELECTED" = "true" ]; then
    BACKGROUND_COLOR=$HIGHLIGHT_25
    PADDING=$PADDINGS
  else
    BACKGROUND_COLOR=$TRANSPARENT
    PADDING=0
  fi

  sketchybar --animate tanh 10 \
             --set "$NAME" icon.highlight="$SELECTED" \
                            label.highlight="$SELECTED" \
                            background.color="$BACKGROUND_COLOR" \
                            icon.padding_left="$PADDING" \
                            label.padding_right="$PADDING"

  CURRENT_SID=$(yabai -m query --spaces --space | jq -r '.index')

  if [[ $SID = $CURRENT_SID ]]; then
    QUERY=$(yabai -m query --windows --space "$SID" | jq '[.[] | select(.scratchpad == "")]')
    IFS=$'\n'
    local APPS=($(echo "$QUERY" | jq -r 'map(select((.title | length) > 0)) | .[].app' | sort -u))
    local CURRENT_APP=$(echo "$QUERY" | jq -r 'map(select((.title | length) > 0)) | .[] | select(.["has-focus"] == true) | .app')
    local LABEL ICON

    # Get space label
    SPACE_LABEL=$(yabai -m query --spaces | jq -r --argjson sid "$SID" '.[] | select(.index == $sid) | .label // ""')
    [[ -z "$SPACE_LABEL" ]] && SPACE_LABEL="$SID"

    debug $FUNCNAME

    for APP in "${APPS[@]}"; do
      local TITLE=$(echo "$QUERY" | jq -r 'map(select((.title | length) > 0 and .app == "'"$APP"'")) | .[0].title')
      ICON=$("$HOME/.config/sketchybar/plugins/app_icon.sh" "$APP" "$TITLE")
      append_focused_app_title "$APP" "$CURRENT_APP" && ICON+=" $APP"
      LABEL+="$ICON"
      [[ ${#APPS[@]} -gt 1 ]] && LABEL+=" "
    done
    unset IFS

    sketchybar --set "space.$SID" label="$SPACE_LABEL $LABEL"
  fi
}


mouse_clicked() {
  if [ "$BUTTON" = "right" ] || [ "$MODIFIER" = "shift" ]; then
    SPACE_NAME="${NAME#*.}"
    SPACE_LABEL="$(osascript -e "return (text returned of (display dialog \"Rename space $SPACE_NAME to:\" default answer \"\" with title \"Space Renamer\" buttons {\"Cancel\", \"Rename\"} default button \"Rename\"))")"
    if [ $? -eq 0 ]; then
      if [ "$SPACE_LABEL" = "" ]; then
        set_space_label "${NAME:6}"
      else
        set_space_label "${NAME:6} $SPACE_LABEL"
      fi
    fi
  else
    yabai -m space --focus $SID 2>/dev/null
  fi
  update_icons
}

set_space_label() {
  sketchybar --set $NAME icon="$@"
}

debug() {
  if [[ "$DEBUG" -eq 1 ]]; then
    echo ---$(date +"%T")---
    echo $1
    echo sender: $SENDER
    echo sid: $SID
    echo app: $CURRENT_APP
    echo ---
  fi
}

case "$SENDER" in
"routine" | "forced" | "space_windows_change")
  create_icons
  ;;
"front_app_switched" | "space_change")
  update_icons
  ;;
"mouse.clicked")
  mouse_clicked
  ;;
esac
