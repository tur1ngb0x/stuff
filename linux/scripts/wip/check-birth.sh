#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
distro-age.sh - Print filesystem birth time, current time (UTC), and age in days

SYNOPSIS
    distro-age.sh

DESCRIPTION
    Reads the "Birth" timestamp from `stat /`, compares it to current UTC time,
    and prints:
        birth: YYYY-MM-DD DDD HH:MM:SS
        today: YYYY-MM-DD DDD HH:MM:SS
        age:   N days

NOTES
    - Birth time may be unavailable on some filesystems.
    - Birth time from `stat` is parsed with its timezone offset, then converted
      to epoch seconds for correct math.
    - Output is always printed in UTC.

OUTPUT
    birth: YYYY-MM-DD DDD HH:MM:SS
    today: YYYY-MM-DD DDD HH:MM:SS
      age: N days

EXAMPLES
    distro-age.sh
EOF
}

die() {
    local message="${1:-Unknown error}"
    echo "ERROR: ${message}" >&2
    exit 1
}

require() {
    local name
    for name in "$@"; do
        command -v "${name}" >/dev/null 2>&1 || die "Missing required command: ${name}"
    done
}

confirm() {
    local prompt="${1:-Continue?}"
    local reply=""

    read -r -p "${prompt} (N/y) " reply
    case "${reply}" in
        y|Y)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

arguments() {
    local argc="${#}"
    local min=0
    local max=0

    if (( argc < min || argc > max )); then
        usage >&2
        die "This script takes no arguments"
    fi
}

get_birth_raw() {
    local birth_line=""

    birth_line="$(
        stat / \
            | awk -F': ' '$1 == " Birth" { print $2 }'
    )"

    if [[ -z "${birth_line}" ]]; then
        die "Could not read Birth time from stat output for: /"
    fi

    if [[ "${birth_line}" == "-" ]]; then
        die "Birth time is not available for: /"
    fi

    echo "${birth_line}"
}

to_epoch_utc() {
    local ts="${1}"
    date -u -d "${ts}" +%s
}

format_utc_from_epoch() {
    local epoch="${1}"
    date -u -d "@${epoch}" +"%Y-%m-%d %a %H:%M:%S"
}

calc_days_between() {
    local start_epoch="${1}"
    local end_epoch="${2}"
    local diff=0

    if (( end_epoch < start_epoch )); then
        die "Current time is earlier than Birth time (clock issue?)"
    fi

    diff=$(( end_epoch - start_epoch ))
    echo $(( diff / 86400 ))
}

main() {
    require stat date awk
    arguments "$@"

    local birth_raw=""
    local birth_epoch=""
    local now_epoch=""
    local birth_fmt=""
    local now_fmt=""
    local age_days=""

    birth_raw="$(get_birth_raw)"
    birth_epoch="$(to_epoch_utc "${birth_raw}")"
    now_epoch="$(date -u +%s)"

    birth_fmt="$(format_utc_from_epoch "${birth_epoch}")"
    now_fmt="$(format_utc_from_epoch "${now_epoch}")"
    age_days="$(calc_days_between "${birth_epoch}" "${now_epoch}")"

    echo "birth: ${birth_fmt}"
    echo "today: ${now_fmt}"
    echo "  age: ${age_days} days"
}

main "$@"
