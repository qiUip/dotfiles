#!/bin/bash

# Load global styles, colors and icons
source "$CONFIG_DIR/globalstyles.sh"

SID=$1
DEBUG=0

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

    # Append app name only if it's the currently focused one
    [[ "$APP" == "$CURRENT_APP" ]] && ICON+=" $APP"

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
      [[ "$APP" == "$CURRENT_APP" ]] && ICON+=" $APP"
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
