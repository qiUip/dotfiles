#!/bin/bash
#
# list of choices
# choices="VPN connect\nVPN disconnect\nMopidy\nPicom"
choices="Mopidy\nPicom"
DMENU="/usr/local/bin/dmenu -i -n -l 15"
# launch dmenu
chosen=$(echo -e "$choices" | $DMENU)
# run the script
case "$chosen" in
    # "Dive connect") [ $(echo -e "Yes\nNo" | $DMENU -p "Confirm?") == "Yes" ] && $HOME/.scripts/some_vpn.sh -c ;;
    # "Dive disconnect") [ $(echo -e "Yes\nNo" | $DMENU -p "Confirm?") == "Yes" ] && $HOME/.scripts/some_vpn.sh -d ;;
    "Mopidy") $HOME/.scripts/mopidy.sh ;;
    "Picom") $HOME/.scripts/picom.sh ;;
esac
