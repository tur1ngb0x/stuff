#!/usr/bin/env bash

{
    grep '^bindsym' ~/.config/i3/config \
        | awk '{ if ($2=="--release") { key=$3; $1=$2=$3="" } else { key=$2; $1=$2="" } sub(/^  */,""); print key "\t" $0 }' \
        | column -t -s "$(printf '\t')" \
        | tee /tmp/i3-bindsym.txt &>/dev/null
} && alacritty -T i3-bindsym.sh -e bash -c "most /tmp/i3-bindsym.txt"


# set $I3_BINDSYM    ~/.config/i3/scripts/i3-bindsym.sh
# set $I3_SET        ~/.config/i3/scripts/i3-set.sh

# bindsym $SUPER+$SHIFT+i $I3_BINDSYM
# bindsym $SUPER+$SHIFT+o $I3_SET

# for_window [title="i3-bindsym.sh"] floating enable, resize set 1600 900, move position center
# for_window [title="i3-set.sh"]     floating enable, resize set 1600 900, move position center
