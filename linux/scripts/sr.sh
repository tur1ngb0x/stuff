#!/usr/bin/env bash

LC_ALL=C
builtin set -euo pipefail

if [[ "${XDG_SESSION_TYPE}" != "x11" ]]; then
    echo "Current session type is: ${XDG_SESSION_TYPE}"
    echo "This script is designed for X11 only."
    exit
fi

if [[ $# -ne 2 ]]; then
    cat << EOF
Usage:
$ screenrecord.sh <fps> <quality>

Examples:
$ screenrecord.sh 60 0  (60 fps, best quality)
$ screenrecord.sh 15 51 (15 fps, worst quality)
EOF
    exit
fi

fps="${1}"
quality="${2}"
output="${HOME}/screenrecord-$(date +%Y%m%d-%H%M%S).mp4"

command ffmpeg \
    -loglevel 'quiet' \
    -f 'x11grab' \
    -s '1920x1080' \
    -r "${fps}" \
    -i "${DISPLAY}" \
    -c:v 'libx264rgb' \
    -preset 'ultrafast' \
    -crf "${quality}" \
    "${output}"

echo ''
#echo '+ find $HOME -mindepth 1 -maxdepth 1 -name "screenrecord*.mp4" | sort'
find "${HOME}" -mindepth 1 -maxdepth 1 -name "screenrecord*.mp4" | sort
