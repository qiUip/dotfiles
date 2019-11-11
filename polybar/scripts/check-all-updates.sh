#!/bin/sh
#source https://github.com/x70b1/polybar-scripts

# if ! updates_aur=$(cower -u 2> /dev/null | wc -l); then
if ! updates=$(zypper --no-refresh lu --best-effort | grep -c 'v |'); then
    updates=0
fi


if [ "$updates" -gt 0 ]; then
    echo " $updates"
else
    echo "0"
fi
