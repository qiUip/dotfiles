#!/bin/bash
#
# list of choices
choices="UTC connect\nUTC nas\nUTC disconnect\nMopidy\nPicom\nWS2"
# launch dmenu
chosen=$(echo -e "$choices" | dmenu -i -n -l 15)
# run the script
case "$chosen" in
    "UTC connect") [ $(echo -e "Yes\nNo" | dmenu -i -n -l 15 -p "Confirm?") == "Yes" ] && $HOME/.scripts/utc.sh -c ;;
    "UTC nas") [ $(echo -e "Yes\nNo" | dmenu -i -n -l 15 -p "Confirm?") == "Yes" ] && $HOME//.scripts/utc.sh -n ;;
    "UTC disconnect") [ $(echo -e "Yes\nNo" | dmenu -i -n -l 15 -p "Confirm?") == "Yes" ] && $HOME/.scripts/utc.sh -d ;;
    "Mopidy") $HOME/.scripts/mopidy.sh ;;
    "Picom") $HOME/.scripts/picom.sh ;;
    "WS2") $HOME/.scripts/workspace2.sh
esac
