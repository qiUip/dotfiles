#!/usr/bin/env sh

find $HOME/.password-store -type f -name '*.gpg' | \
    sed "s|.*/\.password-store/||; s|\.gpg$||" | \
    choose -azd -s 20 -w 20 -b 5E81AC -c A3BE8C -f "Hack Nerd Font Mono"| \
    xargs -r -I{} pass show -c {}
