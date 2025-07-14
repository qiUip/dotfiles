#!/usr/bin/env bash

socket_file=$($HOME/.config/yabai/scripts/emacs_server.sh)
emacs=/opt/homebrew/bin/emacs
emacsclient=/opt/homebrew/bin/emacsclient

echo $socket_file
if [[ $socket_file == "" ]]; then
echo "starting Emacs server..."
$emacs --execute "(server-start)" $@ &
# $emacs --chdir ${pwd} --execute "(server-start)" $@ &
else
$emacsclient -n $@ --socket-name $socket_file -c -a ''
fi
