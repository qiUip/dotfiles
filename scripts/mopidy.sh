#!/usr/bin/env bash

pw=$(pass music-mopidy)

killall -q mopidy
while pgrep -u $UID -x mopidy >/dev/null; do sleep 1; done

mopidy -q -o spotify/password=$pw &

echo "Started mopidy with spotify"
