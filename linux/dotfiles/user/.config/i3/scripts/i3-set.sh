#!/usr/bin/env bash

{
    grep '^set' ~/.config/i3/config \
    | awk '{ var=$2; $1=$2=""; sub(/^  */,""); print var "\t" $0 }' \
    | column -t -s "$(printf '\t')" \
    | tee /tmp/i3-set.txt &>/dev/null
} && alacritty -T i3-set.sh -e bash -c "most /tmp/i3-set.txt"


# set $I3_BINDSYM    ~/.config/i3/scripts/i3-bindsym.sh
# set $I3_SET        ~/.config/i3/scripts/i3-set.sh

# bindsym $SUPER+$SHIFT+i $I3_BINDSYM
# bindsym $SUPER+$SHIFT+o $I3_SET

# for_window [title="i3-bindsym.sh"] floating enable, resize set 1600 900, move position center
# for_window [title="i3-set.sh"]     floating enable, resize set 1600 900, move position center
