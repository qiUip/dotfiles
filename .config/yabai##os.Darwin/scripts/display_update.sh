#!/opt/homebrew/bin/bash

# Get displays
DISPLAYS=($(yabai -m query --displays | jq -r 'sort_by(.id) | .[].id'))
NUM_DISPLAYS=${#DISPLAYS[@]}
MAIN_DISPLAY=${DISPLAYS[0]}
DISP2=${DISPLAYS[1]:-}
DISP3=${DISPLAYS[2]:-}

# Get all spaces sorted by id ascending (assumed stable order)
mapfile -t space_ids_sorted < <(yabai -m query --spaces | jq -r 'sort_by(.id) | .[].id')

destroy_space_ids=()

if [[ $NUM_DISPLAYS -eq 2 ]]; then
  # Move spaces 1-4 to main display
  for i in "${!space_ids_sorted[@]}"; do
    sid=${space_ids_sorted[i]}
    idx=$((i+1))

    if (( idx <= 4 )); then
      yabai -m space --move "$sid" --display "$MAIN_DISPLAY"
    fi

    if (( idx > 9 )); then
      destroy_space_ids+=("$sid")
    fi
  done

elif [[ $NUM_DISPLAYS -eq 3 ]]; then
  # Move spaces according to the plan
  for i in "${!space_ids_sorted[@]}"; do
    sid=${space_ids_sorted[i]}
    idx=$((i+1))

    if (( idx == 1 || idx == 4 )); then
      yabai -m space --move "$sid" --display "$MAIN_DISPLAY"
    elif (( idx == 2 || idx == 3 )); then
      yabai -m space --move "$sid" --display "$DISP2"
    else
      yabai -m space --move "$sid" --display "$DISP3"
    fi

    if (( idx > 9 )); then
      destroy_space_ids+=("$sid")
    fi
  done
else
  echo "Only 2 or 3 display configurations supported."
fi

# Destroy extra spaces
for sid in "${destroy_space_ids[@]}"; do
  yabai -m space --destroy "$sid"
done
