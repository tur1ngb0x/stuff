#!/usr/bin/env bash

if [[ "${XDG_SESSION_TYPE}" == 'x11' ]]; then
    /usr/bin/i3lock \
        --color=000000 \
        --ignore-empty-password \
        --show-failed-attempts

    /usr/bin/xset dpms force off
else
    builtin echo 'not an X11 session'
fi
