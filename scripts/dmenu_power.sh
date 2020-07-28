#!/bin/bash
#
DMENU='dmenu -i -n -l 15'
# list of choices
choices="Lock\nShutdown\nRestart\nHibernate\nSleep\nLogout"
# launch dmenu
chosen=$(echo -e "$choices" | $DMENU)
# run the script
case "$chosen" in
    "Lock"      ) [ $(echo -e "Yes\nNo" | $DMENU -p "Confirm?") == "Yes" ] && $HOME/.scripts/lock.sh;;
    "Shutdown"  ) [ $(echo -e "Yes\nNo" | $DMENU -p "Confirm?") == "Yes" ] && systemctl poweroff;;
    "Restart"   ) [ $(echo -e "Yes\nNo" | $DMENU -p "Confirm?") == "Yes" ] && systemctl reboot ;;
    "Hibernate" ) [ $(echo -e "Yes\nNo" | $DMENU -p "Confirm?") == "Yes" ] && systemctl hibernate ;;
    "Sleep"     ) [ $(echo -e "Yes\nNo" | $DMENU -p "Confirm?") == "Yes" ] && systemctl suspend ;;
    "Logout"    ) [ $(echo -e "Yes\nNo" | $DMENU -p "Confirm?") == "Yes" ] && kill -9 -1 ;;
esac
