#!/usr/bin/env bash

dir="${1:-${PWD}}"

[[ -d "${dir}" ]] || {
    builtin echo "Invalid directory" >&2
    builtin exit 1
}

LC_ALL=C /usr/bin/du -h -d1 -- "${dir}" 2>/dev/null \
| LC_ALL=C /usr/bin/sort -hr \
| /usr/bin/awk '
BEGIN {
    red    = "\033[31m"
    yellow = "\033[33m"
    cyan   = "\033[36m"
    green  = "\033[32m"
    reset  = "\033[0m"
}
{
    size = $1
    $1 = ""
    sub(/^ /, "")
    path = $0

    unit = substr(size, length(size), 1)
    num  = substr(size, 1, length(size) - 1) + 0

    color = ""

    if (unit == "T") {
        color = red
    } else if (unit == "G") {
        color = yellow
    } else if (unit == "M") {
        color = cyan
    } else if (unit == "K") {
        color = green
    }

    printf "%s%7.2f %s%s    %s\n", color, num, unit, reset, path
}'
