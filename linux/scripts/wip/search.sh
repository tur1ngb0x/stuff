#!/usr/bin/env bash

LC_ALL=C
builtin set -euo pipefail

browser="org.mozilla.firefox"

encode() {
    local s="${*}"
    s="${s// /+}"
    printf "%s" "${s}"
}

google() {
    local query="${*}"
    local encoded
    encoded="$(encode "${query}")"
    printf "https://www.google.com/search?q=%s" "${encoded}"
}

youtube() {
    local query="${*}"
    local encoded
    encoded="$(encode "${query}")"
    printf "https://www.youtube.com/results?search_query=%s" "${encoded}"
}

main() {
    local provider="${1}"
    shift

    if [[ "$#" -eq 0 ]]; then
        printf 'usage: search.sh <google|youtube> <query>\n'
        exit
    fi

    local url

    case "${provider}" in
        google) url="$(google "${@}")";;
        youtube) url="$(youtube "${@}")";;
        *) printf 'unknown provider\n'; exit;;
    esac

	(nohup "${browser}" "${url}" &) &>/dev/null
}

main "${@}"
