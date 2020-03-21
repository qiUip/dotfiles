#!/bin/bash
#

choices="UTC connect\nUTC nas\nUTC disconnect\nMopidy"

chosen=$(echo -e "$choices" | dmenu -i -n -l 15)

case "$chosen" in
    "UTC connect") [ $(echo -e "Yes\nNo" | dmenu -i -n -l 15 -p "Confirm?") == "Yes" ] && $HOME/.scripts/utc.sh -c ;;
    "UTC nas") [ $(echo -e "Yes\nNo" | dmenu -i -n -l 15 -p "Confirm?") == "Yes" ] && $HOME//.scripts/utc.sh -n ;;
    "UTC disconnect") [ $(echo -e "Yes\nNo" | dmenu -i -n -l 15 -p "Confirm?") == "Yes" ] && $HOME/.scripts/utc.sh -d ;;
    "Mopidy") $HOME/.scripts/mopidy.sh
esac
