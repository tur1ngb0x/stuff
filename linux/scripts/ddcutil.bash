#!/usr/bin/env bash

_ddcutil() { /usr/bin/ddcutil setvcp 10 "${1}"; }

if [[ -n "${1}" ]]; then
    _ddcutil "${1}"
else
    H=$(/usr/bin/date +%H)
    if (( 10#${H} >= 6 && 10#${H} < 18 )); then
        _ddcutil 100
    else
        _ddcutil 10
    fi
fi
