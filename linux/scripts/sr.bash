#!/usr/bin/env bash

if [[ "${XDG_SESSION_TYPE}" != "x11" ]]; then
    builtin echo 'This script works on x11 only. Exiting.'
    builtin exit
fi

if [[ $# -ne 2 ]]; then
    /usr/bin/cat << EOF
Usage:
  $ sr.sh <fps> <quality>

Examples
  $ sr.sh 60 0  (60 fps, best quality)
  $ sr.sh 15 51 (15 fps, worst quality)
EOF

    builtin exit
fi

fps="${1}"
quality="${2}"

/usr/bin/ffmpeg \
    -loglevel 'quiet' \
    -f 'x11grab' \
    -s '1920x1080' \
    -r "${fps}" \
    -i "${DISPLAY}" \
    -c:v 'libx264rgb' \
    -preset 'ultrafast' \
    -crf "${quality}" \
    "${HOME}/screenrecord-$(/usr/bin/date +%Y%m%d-%H%M%S).mp4"

builtin echo ''

/usr/bin/find \
    "${HOME}" \
    -mindepth 1 \
    -maxdepth 1 \
    -name "screenrecord*.mp4" \
| /usr/bin/sort
