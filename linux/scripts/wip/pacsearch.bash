#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

main() {
    if [[ $# -ne 1 ]]; then
        builtin printf 'usage: %s <query>\n' "${0##*/}" >&2
        builtin exit 1
    fi

    local query
    query="$1"

    local line
    local desc
    local meta
    local component
    local package
    local version
    local status
    local group

    /usr/bin/pacman -Ss -- "${query}" |
    while IFS= read -r line; do
        if [[ "${line}" =~ ^([^/[:space:]]+)/([^[:space:]]+)[[:space:]]+([^[:space:]]+)(.*)$ ]]; then
            component="${BASH_REMATCH[1]}"
            package="${BASH_REMATCH[2]}"
            version="${BASH_REMATCH[3]}"
            meta="${BASH_REMATCH[4]}"

            status=""
            group=""

            [[ "${meta}" == *"[installed]"* ]] && status='*'

            if [[ "${meta}" =~ \(([^()]*)\) ]]; then
                group="${BASH_REMATCH[1]}"
            fi

            if ! IFS= read -r desc; then
                desc=""
            fi

            desc="${desc#"${desc%%[![:space:]]*}"}"

            builtin printf '%s|%s|%s|%s|%s\n' \
                "${status}" \
                "${package}" \
                "${version}" \
                "${component}" \
                "${group}"
        fi
    done |
    LC_ALL=C /usr/bin/sort -t '|' -k1,1 -k5,5 |
    /usr/bin/column \
        -s '|' \
        -N I,PACKAGE,VERSION,COMPONENT,GROUP \
        -t
}

main "$@"
