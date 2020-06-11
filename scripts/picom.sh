
killall -q picom
while pgrep -u $UID -x picom >/dev/null; do sleep 2; done
picom -b
