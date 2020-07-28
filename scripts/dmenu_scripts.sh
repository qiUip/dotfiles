#!/bin/bash
#
# list of choices
choices="UTC connect\nUTC nas\nUTC disconnect\nIC connect\nIC disconnect\nMopidy\nPicom"
DMENU="/usr/local/bin/dmenu -i -n -l 15"
# launch dmenu
chosen=$(echo -e "$choices" | $DMENU)
# run the script
case "$chosen" in
    "UTC connect") [ $(echo -e "Yes\nNo" | $DMENU -p "Confirm?") == "Yes" ] && $HOME/.scripts/utc.sh -c ;;
    "UTC nas") [ $(echo -e "Yes\nNo" | $DMENU  -p "Confirm?") == "Yes" ] && $HOME//.scripts/utc.sh -n ;;
    "UTC disconnect") [ $(echo -e "Yes\nNo" | $DMENU -p "Confirm?") == "Yes" ] && $HOME/.scripts/utc.sh -d ;;
    "IC connect") [ $(echo -e "Yes\nNo" | $DMENU -p "Confirm?") == "Yes" ] && $HOME/.scripts/ic_vpn.sh -c ;;
    "IC disconnect") [ $(echo -e "Yes\nNo" | $DMENU -p "Confirm?") == "Yes" ] && $HOME/.scripts/ic_vpn.sh -d ;;
    "Mopidy") $HOME/.scripts/mopidy.sh ;;
    "Picom") $HOME/.scripts/picom.sh ;;
esac
