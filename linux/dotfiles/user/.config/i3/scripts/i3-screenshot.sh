#!/usr/bin/env bash

scrot -s -f -q 100 -Z 0 -o /tmp/ss.png \
    && xclip -sel clip -t image/png -i /tmp/ss.png \
        && install -D /tmp/ss.png "${HOME}/Pictures/${0##*/}_$(date +%Y%m%d-%H%M%S).png" \
            && notify-send -t 2500 "[${0##*/}]" "screenshot saved to clipboard and disk"
