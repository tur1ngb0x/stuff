#!/usr/bin/env bash

if [[ -n "${1}" ]]; then
    ddcutil setvcp 10 "${1}"
else
    H=$(date +%H)
    if (( 10#${H} >= 6 && 10#${H} < 18 )); then
        ddcutil setvcp 10 100
    else
        ddcutil setvcp 10 10
    fi
fi
