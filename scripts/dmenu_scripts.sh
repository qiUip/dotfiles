#!/bin/bash
#
# list of choices
choices="UTC connect\nUTC nas\nUTC disconnect\nMopidy\nPicom\nWS2"
DMENU="/usr/local/bin/dmenu -i -n -l 15"
# launch dmenu
chosen=$(echo -e "$choices" | $DMENU)
# run the script
case "$chosen" in
    "UTC connect") [ $(echo -e "Yes\nNo" | $DMENU -p "Confirm?") == "Yes" ] && $HOME/.scripts/utc.sh -c ;;
    "UTC nas") [ $(echo -e "Yes\nNo" | $DMENU  -p "Confirm?") == "Yes" ] && $HOME//.scripts/utc.sh -n ;;
    "UTC disconnect") [ $(echo -e "Yes\nNo" | $DMENU -p "Confirm?") == "Yes" ] && $HOME/.scripts/utc.sh -d ;;
    "Mopidy") $HOME/.scripts/mopidy.sh ;;
    "Picom") $HOME/.scripts/picom.sh ;;
    "WS2") $HOME/.scripts/workspace2.sh
esac
