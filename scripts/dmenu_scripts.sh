#!/bin/bash
#
# list of choices
choices="UTC connect\nUTC nas\nUTC disconnect\nIC connect\nIC disconnect\nMopidy\nPicom"
# launch dmenu
chosen=$(echo -e "$choices" | dmenu -i -n -l 15)
# run the script
case "$chosen" in
    "UTC connect") [ $(echo -e "Yes\nNo" | dmenu -i -n -l 15 -p "Confirm?") == "Yes" ] && $HOME/.scripts/utc.sh -c ;;
    "UTC nas") [ $(echo -e "Yes\nNo" | dmenu -i -n -l 15 -p "Confirm?") == "Yes" ] && $HOME//.scripts/utc.sh -n ;;
    "UTC disconnect") [ $(echo -e "Yes\nNo" | dmenu -i -n -l 15 -p "Confirm?") == "Yes" ] && $HOME/.scripts/utc.sh -d ;;
    "IC connect") [ $(echo -e "Yes\nNo" | dmenu -i -n -l 15 -p "Confirm?") == "Yes" ] && $HOME/.scripts/ic_vpn.sh -c ;;
    "IC disconnect") [ $(echo -e "Yes\nNo" | dmenu -i -n -l 15 -p "Confirm?") == "Yes" ] && $HOME/.scripts/ic_vpn.sh -d ;;
    "Mopidy") $HOME/.scripts/mopidy.sh ;;
    "Picom") $HOME/.scripts/picom.sh ;;
esac
