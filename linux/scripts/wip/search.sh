#!/usr/bin/env bash

encode() {
    local s="${*}"

    s="${s// /+}"

    builtin printf "%s" "${s}"
}

google() {
    local query="${*}"
    local encoded

    encoded="$(encode "${query}")"

    builtin printf "https://www.google.com/search?q=%s" "${encoded}"
}

youtube() {
    local query="${*}"
    local encoded
    local filter

    encoded="$(encode "${query}")"
    filter="sp=EgIQAQ%253D%253D"

    builtin printf '%s' "https://www.youtube.com/results?search_query=${encoded}&${filter}"
}

main() {
    local provider="${1:-}"

    shift || true

    if [[ "$#" -eq 0 ]]; then
        builtin printf 'usage: search.sh <google|youtube> <query>\n'
        builtin exit
    fi

    if [[ -z "${BROWSER:-}" ]]; then
        builtin printf 'BROWSER variable is not set\n'
        builtin exit 1
    fi

    local url

    case "${provider}" in
        google)
            url="$(google "${@}")"
            ;;
        youtube)
            url="$(youtube "${@}")"
            ;;
        *)
            builtin printf 'unknown provider\n'
            builtin exit
            ;;
    esac

    (/usr/bin/nohup "${BROWSER}" "${url}" &) &>/dev/null
}

main "${@}"
