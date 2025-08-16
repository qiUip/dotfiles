#!/usr/bin/env sh

find $HOME/.password-store -type f -name '*.gpg' | \
    sed "s|.*/\.password-store/||; s|\.gpg$||" | \
    dmenu -p "passwords" -a --bg-color 2E3440 --text-color ECEFF4 --highlight-color 81A1C1 -r 6 -s --font "Hack Nerd Font Mono" | \
    xargs -r -I{} pass show -c {}
