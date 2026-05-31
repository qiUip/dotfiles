#!/opt/homebrew/bin/bash

set -u

# Simple, conservative yabai space repair.
#
# Goals:
# - Keep exactly these labels available for skhd bindings.
# - Avoid fragile cross-display space moves.
# - Avoid global space reordering.
# - Reuse/relabel spaces that already exist on each display.
# - Move windows back to their original labeled workspace after relabeling.
#
# Layout:
#   1 display: all labels on display 1
#   2 displays: non-dev labels on display 1, dev labels on display 2
#   3 displays: non-dev labels on display 1, dev1/dev2 on display 2, dev3 on display 3

SPACE_LABELS=(main dev1 dev2 dev3 chat files write edit watch)
RUN_ID="$$"
SETTLE_SHORT=0.2
SETTLE_LONG=0.8

log() {
  printf '%s\n' "$*"
}

notify() {
  osascript -e "display notification \"$1\" with title \"Yabai Display Update\"" >/dev/null 2>&1 || true
}

spaces_json() {
  yabai -m query --spaces
}

displays_json() {
  yabai -m query --displays
}

is_expected_label() {
  local wanted="$1" label
  for label in "${SPACE_LABELS[@]}"; do
    [[ "$wanted" == "$label" ]] && return 0
  done
  return 1
}

space_count_for_label() {
  local label="$1"
  spaces_json | jq -r --arg label "$label" '[.[] | select(.label == $label)] | length'
}

windows_for_label() {
  local label="$1"
  spaces_json | jq -r --arg label "$label" '
    [.[] | select(.label == $label) | (.windows // [])[]] | .[]?
  '
}

labels_for_display_position() {
  local position="$1"
  local count="$2"

  if (( count == 1 )); then
    printf '%s\n' main dev1 dev2 dev3 chat files write edit watch
  elif (( count == 2 )); then
    case "$position" in
      1) printf '%s\n' main chat files write edit watch ;;
      2) printf '%s\n' dev1 dev2 dev3 ;;
    esac
  else
    case "$position" in
      1) printf '%s\n' main chat files write edit watch ;;
      2) printf '%s\n' dev1 dev2 ;;
      3) printf '%s\n' dev3 ;;
    esac
  fi
}

space_indices_for_display() {
  local display="$1"
  spaces_json | jq -r --argjson display "$display" '
    [.[] | select(.display == $display) | .index] | sort | .[]
  '
}

create_space_on_display() {
  local display="$1"

  log "Creating space on display $display"
  yabai -m display "$display" --focus >/dev/null 2>&1 || true
  sleep 0.2
  yabai -m space --create >/dev/null 2>&1 || return 1
  sleep 0.5
}

ensure_space_count() {
  local display="$1"
  local required="$2"
  local current attempts=0

  current=$(space_indices_for_display "$display" | wc -l | tr -d ' ')
  while (( current < required && attempts < 5 )); do
    if ! create_space_on_display "$display"; then
      log "WARNING: Could not create space on display $display"
      break
    fi
    current=$(space_indices_for_display "$display" | wc -l | tr -d ' ')
    attempts=$((attempts + 1))
  done

  if (( current < required )); then
    log "WARNING: Display $display has $current spaces but wants $required labels"
    return 1
  fi

  return 0
}

snapshot_windows() {
  local label var count

  log "Snapshotting windows by current labels..."
  for label in "${SPACE_LABELS[@]}"; do
    var="WINDOWS_${label}"
    printf -v "$var" '%s' "$(windows_for_label "$label")"
    count=$(printf '%s\n' "${!var}" | sed '/^$/d' | wc -l | tr -d ' ')
    log "  $label: $count window(s)"
  done
}

clear_expected_labels() {
  local idx label tmp

  log "Temporarily clearing managed labels..."
  while IFS=$'\t' read -r idx label; do
    [[ -z "$idx" ]] && continue
    if is_expected_label "$label" || [[ "$label" == __repair_* ]]; then
      tmp="__repair_${RUN_ID}_${idx}"
      yabai -m space "$idx" --label "$tmp" >/dev/null 2>&1 || \
        log "WARNING: Could not temporarily relabel space $idx"
      sleep "$SETTLE_SHORT"
    fi
  done < <(spaces_json | jq -r '.[] | [.index, (.label // "")] | @tsv')

  log "Waiting for label clearing to settle..."
  sleep "$SETTLE_LONG"
}

assign_labels() {
  local display="$1"
  local position="$2"
  local -a labels spaces
  local i label idx max

  mapfile -t labels < <(labels_for_display_position "$position" "$NUM_DISPLAYS")
  (( ${#labels[@]} == 0 )) && return 0

  ensure_space_count "$display" "${#labels[@]}" || true
  mapfile -t spaces < <(space_indices_for_display "$display")

  max=${#labels[@]}
  (( ${#spaces[@]} < max )) && max=${#spaces[@]}

  log "Assigning display $display labels: ${labels[*]}"
  for (( i = 0; i < max; i++ )); do
    label="${labels[$i]}"
    idx="${spaces[$i]}"
    log "  space $idx -> $label"
    yabai -m space "$idx" --label "$label" >/dev/null 2>&1 || \
      log "WARNING: Could not label space $idx as $label"
    sleep "$SETTLE_SHORT"
  done

  log "Waiting for display $display label assignment to settle..."
  sleep "$SETTLE_LONG"
}

move_windows_back() {
  local label var windows window_id

  log "Waiting before moving windows back..."
  sleep "$SETTLE_LONG"

  log "Moving windows back to their labels..."
  for label in "${SPACE_LABELS[@]}"; do
    var="WINDOWS_${label}"
    windows="${!var:-}"
    [[ -z "$windows" ]] && continue

    while read -r window_id; do
      [[ -z "$window_id" ]] && continue
      yabai -m window "$window_id" --space "$label" >/dev/null 2>&1 || \
        log "WARNING: Could not move window $window_id to $label"
      sleep "$SETTLE_SHORT"
    done <<< "$windows"
  done

  log "Waiting for window moves to settle..."
  sleep "$SETTLE_LONG"
}

cleanup_empty_extras() {
  local focused idx
  local -a extras

  focused=$(yabai -m query --spaces --space | jq -r '.index' 2>/dev/null || true)
  mapfile -t extras < <(spaces_json | jq -r '
    [.[] |
      select(
        (((.label // "") == "") or ((.label // "") | startswith("__repair_"))) and
        ((.windows // []) | length == 0)
      ) |
      .index
    ] | sort | reverse | .[]
  ')

  (( ${#extras[@]} == 0 )) && return 0

  log "Cleaning empty unmanaged spaces: ${extras[*]}"
  for idx in "${extras[@]}"; do
    if [[ "$idx" == "$focused" ]]; then
      yabai -m space --focus main >/dev/null 2>&1 || true
      sleep 0.2
    fi
    yabai -m space "$idx" --destroy >/dev/null 2>&1 || \
      log "WARNING: Could not destroy extra space $idx"
  done
}

verify_labels() {
  local label count ok=0

  log "Final spaces:"
  spaces_json | jq -r '.[] | "  Space \(.index): label=\"\(.label // "")\", display=\(.display), windows=\((.windows // []) | length)"'

  for label in "${SPACE_LABELS[@]}"; do
    count=$(space_count_for_label "$label")
    if (( count != 1 )); then
      log "WARNING: label '$label' count is $count"
      ok=1
    fi
  done

  return "$ok"
}

log "Waiting for macOS display/space state to settle..."
sleep 2

mapfile -t ALL_DISPLAYS < <(displays_json | jq -r 'sort_by(.index) | .[].index')
FOCUSED_DISPLAY=$(yabai -m query --displays --display | jq -r '.index // empty' 2>/dev/null || true)

DISPLAYS=()
if [[ -n "$FOCUSED_DISPLAY" ]]; then
  DISPLAYS+=("$FOCUSED_DISPLAY")
fi

for display in "${ALL_DISPLAYS[@]}"; do
  [[ "$display" != "$FOCUSED_DISPLAY" ]] && DISPLAYS+=("$display")
done

NUM_DISPLAYS=${#DISPLAYS[@]}

if (( NUM_DISPLAYS < 1 )); then
  log "ERROR: No displays detected"
  notify "No displays detected"
  exit 1
fi

if (( NUM_DISPLAYS > 3 )); then
  log "WARNING: More than 3 displays detected; only first 3 are managed"
fi

log "Detected $NUM_DISPLAYS display(s): ${ALL_DISPLAYS[*]}"
log "Focused display: ${FOCUSED_DISPLAY:-unknown}"
log "Logical display order: ${DISPLAYS[*]}"

snapshot_windows
clear_expected_labels

for i in "${!DISPLAYS[@]}"; do
  position=$((i + 1))
  (( position > 3 )) && continue
  assign_labels "${DISPLAYS[$i]}" "$position"
done

move_windows_back
cleanup_empty_extras

if verify_labels; then
  notify "Display update complete"
  log "Display update complete"
else
  notify "Display update completed with warnings"
  log "Display update completed with warnings"
fi
