#!/bin/bash
#
# list of choices
choices="Dive connect\nDive disconnect\nMopidy\nPicom"
DMENU="/usr/local/bin/dmenu -i -n -l 15"
# launch dmenu
chosen=$(echo -e "$choices" | $DMENU)
# run the script
case "$chosen" in
    "Dive connect") [ $(echo -e "Yes\nNo" | $DMENU -p "Confirm?") == "Yes" ] && $HOME/.scripts/dive_vpn.sh -c ;;
    "Dive disconnect") [ $(echo -e "Yes\nNo" | $DMENU -p "Confirm?") == "Yes" ] && $HOME/.scripts/dive_vpn.sh -d ;;
    "Mopidy") $HOME/.scripts/mopidy.sh ;;
    "Picom") $HOME/.scripts/picom.sh ;;
esac
