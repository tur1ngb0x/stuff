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

    red_hi    = "\033[1;7;31m"
    yellow_hi = "\033[1;7;33m"
    cyan_hi   = "\033[1;7;36m"
    green_hi  = "\033[1;7;32m"

    hi    = "\033[1;7m"
    reset = "\033[0m"
}
{
    size = $1
    $1 = ""
    sub(/^ /, "")
    path = $0

    unit = substr(size, length(size), 1)
    num  = substr(size, 1, length(size) - 1) + 0

    color = ""
    path_style = ""

    if (unit == "T") {
        color = (NR == 1 ? red_hi : red)
    } else if (unit == "G") {
        color = (NR == 1 ? yellow_hi : yellow)
    } else if (unit == "M") {
        color = (NR == 1 ? cyan_hi : cyan)
    } else if (unit == "K") {
        color = (NR == 1 ? green_hi : green)
    }

    if (NR == 1)
        path_style = hi

    printf "%s%7.2f %s%s | %s'\''%s'\''%s\n",
        color, num, unit, reset,
        path_style, path, reset
}'
