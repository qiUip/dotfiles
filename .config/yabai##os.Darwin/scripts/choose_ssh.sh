#!/usr/bin/env zsh

config_file="$HOME/.ssh/config"

host_aliases=("${(@f)$(awk '/^Host / {
  for (i = 2; i <= NF; i++) if ($i !~ /[*?]/) print $i
}' "$config_file")}")

selected_host=$(printf '%s\n' "${host_aliases[@]}" | choose -azdS -s 20 -w 20 -b 5E81AC -c A3BE8C -f "Hack Nerd Font Mono")
[[ -z $selected_host ]] && exit 0

kitty --single-instance --instance-group remote -T $selected_host -e sh -c "tmux new-session -s '${selected_host}' 'kitten ssh ${selected_host}'"
