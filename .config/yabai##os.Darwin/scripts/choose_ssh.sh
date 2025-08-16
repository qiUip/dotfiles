#!/usr/bin/env zsh

config_file="$HOME/.ssh/config"

host_aliases=("${(@f)$(awk '/^Host / {
  for (i = 2; i <= NF; i++) if ($i !~ /[*?]/) print $i
}' "$config_file")}")

selected_host=$(printf '%s\n' "${host_aliases[@]}" | dmenu -p "ssh" -a --bg-color 2E3440 --text-color ECEFF4 --highlight-color 81A1C1 -r 8 -s --font "Hack Nerd Font Mono")
[[ -z $selected_host ]] && exit 0

kitty --single-instance --instance-group remote -T $selected_host -e sh -c "tmux new-session -s '${selected_host}' 'kitten ssh ${selected_host}'"
