#!/bin/bash

set_icon() {
  source "$CONFIG_DIR/colors.sh"
  source "$CONFIG_DIR/icons.sh"

  COLOR=$LABEL_COLOR

  SPACE=$(yabai -m query --spaces --space)
  LAYOUT=$(echo "$SPACE" | jq -r '.type')
  MAIN_VARIANT=$(echo "$SPACE" | jq -r '.["main-variant"]')

  WINDOW=$(yabai -m query --windows --window)
  read -r FLOATING SPLIT PARENT FULLSCREEN STICKY STACK_INDEX <<<$(echo "$WINDOW" | jq -rc '.["is-floating", "split-type", "has-parent-zoom", "has-fullscreen-zoom", "is-sticky", "stack-index"]')

  if [[ $LAYOUT == "bsp" ]] && [[ $STACK_INDEX -gt 0 ]]; then
    LAST_STACK_INDEX=$(yabai -m query --windows --window stack.last | jq '.["stack-index"]')
    ICON=$YABAI_STACK
    LABEL="$(printf "%s/%s  " "$STACK_INDEX" "$LAST_STACK_INDEX")"
    COLOR=$YELLOW
  elif [[ $FLOATING == "true" ]]; then
    ICON=$YABAI_FLOAT
  elif [[ $PARENT == "true" ]]; then
    ICON="􁈔"
  elif [[ $FULLSCREEN == "true" ]]; then
    ICON=$YABAI_FULLSCREEN_ZOOM
  elif [[ $LAYOUT == "main-stack" ]]; then
    if [[ $MAIN_VARIANT == "main-center" ]]; then
      ICON=$YABAI_MAIN_THREE_COLUMN
    else
      ICON=$YABAI_MAIN_TWO_COLUMN
    fi
  elif [[ $SPLIT == "vertical" ]]; then
    ICON=$YABAI_SPLIT_VERTICAL
  elif [[ $SPLIT == "horizontal" ]]; then
    ICON=$YABAI_SPLIT_HORIZONTAL
  else
    ICON=$YABAI_GRID
  fi

  args=(--bar border_color=$COLOR --animate sin 10 --set $NAME icon=$ICON icon.color=$COLOR)

  [ -z "$LABEL" ] && args+=(label.drawing=off) ||
    args+=(label.drawing=on label="$LABEL" label.color=$COLOR)

  [ -z "$ICON" ] && args+=(icon.width=0) ||
    args+=(icon="$ICON")

  sketchybar -m "${args[@]}"
}

mouse_clicked() {

  yabai_mode=$(yabai -m query --spaces --space | jq -r .type)

  case "$yabai_mode" in
  bsp)
    yabai -m config layout main-stack
    ;;
  main-stack)
    yabai -m config layout float
    ;;
  float)
    yabai -m config layout bsp
    ;;
  esac

  set_icon
}

case "$SENDER" in
"mouse.clicked" | "alfred_trigger")
  mouse_clicked
  ;;
"window_focus" | "front_app_switched")
  set_icon
  ;;
esac
