#!/bin/bash

# Load global styles, colors and icons
source "$CONFIG_DIR/globalstyles.sh"

SID=$1
DEBUG=0

create_icons() {

  QUERY=$(yabai -m query --windows --space "$SID")

  IFS=$'\n'
  local APPS=($(echo "$QUERY" | jq -r 'map(select((.title | length) > 0)) | .[].app' | sort -u))
  local CURRENT_APP=$(echo "$QUERY" | jq -r 'map(select((.title | length) > 0)) | .[] | select(.["has-focus"] == true) | .app')
  # local APPS=($(echo "$QUERY" | jq -r '.[].app' | sort -u))
  # local CURRENT_APP=$(echo "$QUERY" | jq -r '.[] | select(.["has-focus"] == true) | .app')
  local LABEL ICON BADGE

  debug $FUNCNAME

  for APP in "${APPS[@]}"; do

    ICON=$("$HOME/.config/sketchybar/plugins/app_icon.sh" "$APP")

    if [[ "$APP" == "Messages" ]]; then
      BADGE=$(sqlite3 ~/Library/Messages/chat.db "SELECT text FROM message WHERE is_read=0 AND is_from_me=0 AND text!='' AND date_read=0" | wc -l | awk '{$1=$1};1')
    else
      BADGE=$(lsappinfo -all info -only StatusLabel "$APP" | sed -nr 's/\"StatusLabel\"=\{ \"label\"=\"(.+)\" \}$/\1/p')
    fi

    if [[ "$APP" == "$CURRENT_APP" ]]; then
      ICON+=" $APP"
      if [[ -n "$BADGE" ]]; then
        ICON+="$(set_badge $BADGE)"
      fi
    elif [[ -n "$BADGE" ]]; then
      ICON+=" $(set_badge $BADGE)"
    fi

    LABEL+="$ICON"

    if ((${#APPS[@]} > 1)); then
      LABEL+=" "
    fi

  done

  unset IFS

  sketchybar --set $NAME label="$LABEL"
}

update_icons() {

# The $SELECTED variable is available for space components and indicates if
# the space invoking this script (with name: $NAME) is currently selected:
# https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-an-item

  if [ "$SELECTED" = "true" ]; then
    BACKGROUND_COLOR=$HIGHLIGHT_25
    PADDING=$PADDINGS
  else
    PADDING=0
  fi

    sketchybar --animate tanh 10                              \
               --set $NAME icon.highlight=$SELECTED           \
                           label.highlight=$SELECTED          \
                           background.color=$BACKGROUND_COLOR \
                           icon.padding_left=$PADDING         \
                           label.padding_right=$PADDING

  CURRENT_SID=$(yabai -m query --spaces --space | jq -r '.index')
  # PREV_SID=$(yabai -m query --spaces --space prev | jq -r '.index')

  if [[ $SID = $CURRENT_SID ]]; then

    SID=$CURRENT_SID

    QUERY=$(yabai -m query --windows --space "$SID")

    IFS=$'\n'
    local APPS=($(echo "$QUERY" | jq -r 'map(select((.title | length) > 0)) | .[].app' | sort -u))
    local CURRENT_APP=$(echo "$QUERY" | jq -r 'map(select((.title | length) > 0)) | .[] | select(.["has-focus"] == true) | .app')
    # local APPS=($(echo "$QUERY" | jq -r '.[].app' | sort -u))
    # local CURRENT_APP=$(echo "$QUERY" | jq -r '.[] | select(.["has-focus"] == true) | .app')
    local LABEL ICON BADGE

    debug $FUNCNAME

    for APP in "${APPS[@]}"; do

      ICON=$("$HOME/.config/sketchybar/plugins/app_icon.sh" "$APP")

      if [[ "$APP" == "Messages" ]]; then
        BADGE=$(sqlite3 ~/Library/Messages/chat.db "SELECT text FROM message WHERE is_read=0 AND is_from_me=0 AND text!='' AND date_read=0" | wc -l | awk '{$1=$1};1')
      else
        BADGE=$(lsappinfo -all info -only StatusLabel "$APP" | sed -nr 's/\"StatusLabel\"=\{ \"label\"=\"(.+)\" \}$/\1/p')
      fi

      if [[ "$APP" == "$CURRENT_APP" ]]; then
        ICON+=" $APP"
        if [[ -n "$BADGE" ]]; then
          ICON+="$(set_badge $BADGE)"
        fi
      elif [[ -n "$BADGE" ]]; then
        ICON+=" $(set_badge $BADGE)"
      fi

      LABEL+="$ICON"

      if ((${#APPS[@]} > 1)); then
        LABEL+=" "
      fi

    done
    sketchybar --set space.$SID label="$LABEL"
    unset IFS
  fi
}

set_badge() {
  if (($1 < 10)); then
    ICONS=(􀀻 􀀽 􀀿 􀁁 􀁃 􀁅 􀁇 􀁉 􀁋)
    echo "${ICONS[$1 - 1]}"
  else
    echo "􀍢"
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
