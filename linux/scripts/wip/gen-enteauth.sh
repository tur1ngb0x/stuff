#!/usr/bin/env bash

LC_ALL=C
set -euo pipefail

usage() {
    cat <<EOF
DESCRIPTION:
    Generate TOTP codes from an Ente Auth plaintext export.

USAGE:
    ${0##*/} <ente-auth-export.txt>
EOF
}

require_commands() {
    local cmd

    for cmd in date oathtool sed column timedatectl; do
        command -v "${cmd}" >/dev/null 2>&1 || {
            printf 'Error: required command not found: %s\n' "${cmd}" >&2
            exit 1
        }
    done
}

generate_totp() {
    local secret=$1

    oathtool \
        --base32 \
        --totp=SHA1 \
        --time-step-size=30 \
        "${secret}"
}

generate_totp_at() {
    local secret=$1
    local epoch=$2

    oathtool \
        --base32 \
        --totp=SHA1 \
        --time-step-size=30 \
        --now="@${epoch}" \
        "${secret}"
}

cleanup() {
    printf '\033[H\033[J'
    exit 0
}

main() {
    if [[ $# -ne 1 ]]; then
        usage
        exit 1
    fi

    local export_file=$1

    [[ -f "${export_file}" ]] || {
        printf 'Error: file not found: %s\n' "${export_file}" >&2
        exit 1
    }

    require_commands

    trap cleanup INT TERM

    while true; do
        local epoch_current
        local epoch_next
        local seconds_current
        local seconds_next

        epoch_current=$(date +%s)
        seconds_current=$((epoch_current % 60))

        if (( seconds_current < 30 )); then
            seconds_next=$((30 - seconds_current))
        else
            seconds_next=$((60 - seconds_current))
        fi

        epoch_next=$((epoch_current + seconds_next))

        printf '\033[H\033[J'

        # timedatectl status
        {
            printf 'TIME * %s\n' "$(date '+%Y-%m-%d %a %H:%M:%S %Z')"
            printf 'TZ * %s\n' "$(timedatectl show -p Timezone --value)"
            printf 'SYNC * %s\n' "$(timedatectl show -p NTPSynchronized --value)"
            printf 'NTP * %s\n' "$(timedatectl show -p NTP --value)"
            printf 'RTC * %s\n' "$(timedatectl show -p LocalRTC --value)"
        } | column -s '*' -o ':' -t
        printf '\n'

        while IFS=$'\t' read -r account secret; do
            printf '%s\t%s\t%s\n' \
                "${account}" \
                "$(generate_totp "${secret}")" \
                "$(generate_totp_at "${secret}" "${epoch_next}")"
        done < <(
            sed -n \
                's#^[^:]*:[^:]*:\([^?]*\)?.*&secret=\([^&]*\)&codeDisplay=.*#\1\t\2#p' \
                "${export_file}"
        ) | column -t -s $'\t' -N ACCOUNT,CURRENT,NEXT -R 2,3

        printf '\n'

        while (( seconds_next > 0 )); do
            printf '\rRefreshing current TOTPs in: %2ds' "${seconds_next}"
            sleep 1
            ((seconds_next--))
        done
    done
}

main "$@"
