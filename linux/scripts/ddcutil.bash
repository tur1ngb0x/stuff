#!/usr/bin/env bash

if [[ -n "${1}" ]]; then
    /usr/bin/ddcutil setvcp 10 "${1}"
else
    H=$(/usr/bin/date +%H)
    if (( 10#${H} >= 6 && 10#${H} < 18 )); then
        /usr/bin/ddcutil setvcp 10 100
    else
        /usr/bin/ddcutil setvcp 10 10
    fi
fi
