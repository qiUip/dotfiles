#!/usr/bin/env bash

killall -q picom
i3-msg "workspace 2; append_layout /home/mashy/.i3/workspace-2.json"
termite & termite & termite & termite & termite &
while pgrep -u $UID -x picom >/dev/null; do sleep 0.5; done
picom -b
