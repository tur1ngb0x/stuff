#!/usr/bin/env bash

set -x

# get touchpad device id
id_touchpad="$(xinput list \
    | grep -i "touchpad" \
    | head -n 1 \
    | sed -n 's/.*id=\([0-9]\+\).*/\1/p')"

# get touchpad properties
touchpad_props="$(xinput list-props "${id_touchpad}")"

# get tapping enabled for touchpad
id_tap_click="$(printf '%s\n' "${touchpad_props}" \
    | grep -i "Tapping Enabled (" \
    | head -n 1 \
    | sed -n 's/.*(\([0-9]\+\)).*/\1/p')"

# get natural scrolling for touchpad
id_natural_scroll="$(printf '%s\n' "${touchpad_props}" \
    | grep -i "Natural Scrolling Enabled (" \
    | head -n 1 \
    | sed -n 's/.*(\([0-9]\+\)).*/\1/p')"

# get scrolling pixel distance for touchpad
id_scroll_dist="$(printf '%s\n' "${touchpad_props}" \
    | grep -i "Scrolling Pixel Distance (" \
    | head -n 1 \
    | sed -n 's/.*(\([0-9]\+\)).*/\1/p')"

# tap to click
xinput --set-prop "${id_touchpad}" "${id_tap_click}" 1

# natural scrolling
xinput --set-prop "${id_touchpad}" "${id_natural_scroll}" 1

# scroll speed
xinput --set-prop "${id_touchpad}" "${id_scroll_dist}" 10
