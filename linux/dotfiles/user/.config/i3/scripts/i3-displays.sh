#!/usr/bin/env bash

set -exuo pipefail

internal="$(xrandr --query | awk '/^eDP-[0-9]+ connected/ {print $1; exit}')"
[ -z "${internal}" ] && exit 0

external="$(xrandr --query | awk '/^HDMI-[0-9]+ connected/ {print $1; exit}')"
[ -z "${external}" ] && exit 0

display_choice="$(zenity --list \
    --title="Displays" \
    --text="Select display mode" \
    --radiolist \
    --column="Pick" \
    --column="Mode" \
    --height=220 \
    TRUE  "Enable both" \
    FALSE "Internal only" \
    FALSE "External only" \
)"

[ -z "${display_choice}" ] && exit 0

case "${display_choice}" in
    "Enable both")
        [ -n "${internal}" ] && xrandr --output "${internal}" --auto --primary
        [ -n "${external}" ] && xrandr --output "${external}" --auto --same-as "${internal}"
        ;;
    "Internal only")
        [ -n "${internal}" ] && xrandr --output "${internal}" --auto --primary
        [ -n "${external}" ] && xrandr --output "${external}" --off
        ;;
    "External only")
        [ -n "${external}" ] && xrandr --output "${external}" --auto --primary
        [ -n "${internal}" ] && xrandr --output "${internal}" --off
        ;;
esac

brightness_choice="$(zenity --list \
    --title="Brightness" \
    --text="Select brightness" \
    --radiolist \
    --column="Pick" \
    --column="Value" \
    --height=220 \
    FALSE  "1" \
    FALSE "25" \
    FALSE "50" \
    FALSE "75" \
    TRUE "100" \
)"

[ -z "${brightness_choice}" ] && exit 0

(( brightness_choice < 1 )) && brightness_choice=1
(( brightness_choice > 100 )) && brightness_choice=100

[ -n "${internal}" ] && brightnessctl set "${brightness_choice}%"
[ -n "${external}" ] && ddcutil setvcp 10 "${brightness_choice}"
