#!/opt/homebrew/bin/bash

# Space labels (must match yabairc configuration)
SPACE_LABELS=(main dev1 dev2 dev3 chat files write edit watch)

# Get displays (sorted by index for consistent left-to-right order)
DISPLAYS=($(yabai -m query --displays | jq -r 'sort_by(.index) | .[].index'))
NUM_DISPLAYS=${#DISPLAYS[@]}
MAIN_DISPLAY=${DISPLAYS[0]}
DISP2=${DISPLAYS[1]:-}
DISP3=${DISPLAYS[2]:-}

echo "Detected $NUM_DISPLAYS display(s)"
echo "Displays: Main=$MAIN_DISPLAY, 2nd=$DISP2, 3rd=$DISP3"

# Verify all labeled spaces exist
echo "Verifying labeled spaces..."
echo "Expected labels: ${SPACE_LABELS[*]}"
echo ""

MISSING_LABELS=()
for label in "${SPACE_LABELS[@]}"; do
  if ! yabai -m query --spaces | jq -e ".[] | select(.label == \"$label\")" >/dev/null 2>&1; then
    echo "ERROR: Space with label '$label' not found!"
    MISSING_LABELS+=("$label")
  else
    echo "  ✓ Found space '$label'"
  fi
done

if (( ${#MISSING_LABELS[@]} > 0 )); then
  echo ""
  echo "FATAL: Missing ${#MISSING_LABELS[@]} labeled space(s): ${MISSING_LABELS[*]}"
  echo "Aborting to prevent data loss."
  exit 1
fi

echo ""
echo "All 9 labeled spaces verified ✓"

if (( NUM_DISPLAYS == 2 )); then
  echo "Configuring for 2 displays..."
  echo "Layout: Main(main,dev1,dev2,dev3) | Second(chat,files,write,edit,watch)"

  # Move spaces to main display
  for label in main dev1 dev2 dev3; do
    echo "Moving space '$label' to display $MAIN_DISPLAY"
    yabai -m space "$label" --display "$MAIN_DISPLAY" 2>/dev/null || echo "Warning: Failed to move space '$label'"
  done

  # Move spaces to second display
  for label in chat files write edit watch; do
    echo "Moving space '$label' to display $DISP2"
    yabai -m space "$label" --display "$DISP2" 2>/dev/null || echo "Warning: Failed to move space '$label'"
  done

elif (( NUM_DISPLAYS == 3 )); then
  echo "Configuring for 3 displays..."
  echo "Layout: Main(main,dev3) | Second(dev1,dev2) | Third(chat,files,write,edit,watch)"

  # Spaces to main display
  for label in main dev3; do
    echo "Moving space '$label' to display $MAIN_DISPLAY"
    yabai -m space "$label" --display "$MAIN_DISPLAY" 2>/dev/null || echo "Warning: Failed to move space '$label'"
  done

  # Spaces to second display
  for label in dev1 dev2; do
    echo "Moving space '$label' to display $DISP2"
    yabai -m space "$label" --display "$DISP2" 2>/dev/null || echo "Warning: Failed to move space '$label'"
  done

  # Spaces to third display
  for label in chat files write edit watch; do
    echo "Moving space '$label' to display $DISP3"
    yabai -m space "$label" --display "$DISP3" 2>/dev/null || echo "Warning: Failed to move space '$label'"
  done

elif (( NUM_DISPLAYS == 1 )); then
  echo "Configuring for 1 display (reordering spaces)..."
  echo "Layout: All spaces (main,dev1,dev2,dev3,chat,files,write,edit,watch) on main display"

  # Ensure all spaces are on the main display
  for label in "${SPACE_LABELS[@]}"; do
    echo "Ensuring space '$label' is on display $MAIN_DISPLAY"
    yabai -m space "$label" --display "$MAIN_DISPLAY" 2>/dev/null || echo "Warning: Failed to move space '$label'"
  done

  # Reorder spaces to match expected order
  echo "Reordering spaces..."
  for i in "${!SPACE_LABELS[@]}"; do
    label="${SPACE_LABELS[i]}"
    target_index=$((i + 1))  # indices are 1-based

    # Get current index of this labeled space
    current_index=$(yabai -m query --spaces | jq -r ".[] | select(.label == \"$label\") | .index")

    if [[ "$current_index" != "$target_index" ]]; then
      echo "Moving space '$label' from index $current_index to $target_index"
      # Move space to correct position by swapping
      yabai -m space "$label" --move "$target_index" 2>/dev/null || echo "Warning: Failed to reorder space '$label'"
    fi
  done

else
  echo "Only 1, 2, or 3 display configurations supported (detected $NUM_DISPLAYS)"
  exit 1
fi

echo ""
echo "=== Post-redistribution verification ==="

# Verify all labeled spaces still exist after moving
echo "Re-verifying all labeled spaces are present..."
MISSING_AFTER=()
for label in "${SPACE_LABELS[@]}"; do
  if ! yabai -m query --spaces | jq -e ".[] | select(.label == \"$label\")" >/dev/null 2>&1; then
    echo "  ✗ MISSING: Space '$label' disappeared after redistribution!"
    MISSING_AFTER+=("$label")
  else
    echo "  ✓ Space '$label' still present"
  fi
done

if (( ${#MISSING_AFTER[@]} > 0 )); then
  echo ""
  echo "FATAL: ${#MISSING_AFTER[@]} labeled space(s) lost during redistribution: ${MISSING_AFTER[*]}"
  echo "This should not happen. Aborting space destruction to prevent further data loss."
  echo ""
  echo "All current spaces:"
  yabai -m query --spaces | jq -r '.[] | "  Space \(.index): label=\"\(.label // "NONE")\", display=\(.display)"'
  exit 1
fi

echo ""
echo "=== Checking for unlabeled spaces ==="

# Show all current spaces with their labels for debugging
echo "Current spaces:"
yabai -m query --spaces | jq -r '.[] | "  Space \(.index): label=\"\(.label // "NONE")\", display=\(.display)"'

# Only destroy unlabeled spaces when on multiple displays
# On single display, we just reordered - don't destroy anything
if (( NUM_DISPLAYS >= 2 )); then
  # Get spaces that don't have one of our expected labels
  EXPECTED_LABELS="main|dev1|dev2|dev3|chat|files|write|edit|watch"

  # Find unlabeled spaces (label is null, empty, or not in our expected list)
  mapfile -t UNLABELED_SPACES < <(yabai -m query --spaces | jq -r --arg labels "$EXPECTED_LABELS" '
    .[] |
    select(
      .label == null or
      .label == "" or
      (.label | test($labels) | not)
    ) |
    .index
  ')

  if (( ${#UNLABELED_SPACES[@]} > 0 )); then
    echo ""
    echo "Found ${#UNLABELED_SPACES[@]} unlabeled/unexpected space(s) to destroy: ${UNLABELED_SPACES[*]}"

    # Get current focused space to avoid destroying it
    FOCUSED_SPACE=$(yabai -m query --spaces --space | jq -r '.index')

    for space_idx in "${UNLABELED_SPACES[@]}"; do
      # If we're about to destroy the focused space, focus a labeled space first
      if [[ "$space_idx" == "$FOCUSED_SPACE" ]]; then
        echo "Focused space is being destroyed, switching to 'main' space"
        yabai -m space --focus main
        sleep 0.2  # Give focus time to change
      fi

      echo "Destroying unlabeled space $space_idx"
      yabai -m space "$space_idx" --destroy 2>/dev/null || echo "Warning: Failed to destroy space $space_idx"
    done
  else
    echo "No unlabeled spaces found ✓"
  fi
else
  echo "Single display mode - skipping destruction (only reordered spaces)"
fi

echo "Display update complete"

# Show notification
osascript -e "display notification \"Redistributed 9 spaces across $NUM_DISPLAYS displays\" with title \"Display Update\" subtitle \"Complete\""
