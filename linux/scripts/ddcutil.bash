#!/usr/bin/env bash

hour="$(/usr/bin/date +%H)"

if (( 10#"${hour}" >= 6 && 10#"${hour}" < 18 )); then
    brightness="100"
    mode="prefer-light"
    theme="Adwaita"
else
    brightness="1"
    mode="prefer-dark"
    theme="Adwaita-dark"
fi

{ builtin set -x ;} &> /dev/null

# brightness
/usr/bin/brightnessctl --quiet set "${brightness}"%
/usr/bin/ddcutil setvcp 10 "${brightness}"

{ builtin set +x ;} &> /dev/null
