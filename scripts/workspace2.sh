#!/usr/bin/env bash

killall -q picom
i3-msg "workspace 2; append_layout /home/mashy/.config/i3/workspaces/workspace-2.json"
st & st & st & st & st
while pgrep -u $UID -x picom >/dev/null; do sleep 0.5; done
picom -b
