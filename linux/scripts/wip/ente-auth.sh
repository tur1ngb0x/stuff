#!/usr/bin/env bash

LC_ALL=C
builtin set -euo pipefail

usage() {
    cat << EOF
Descripton:
  Generates TOTP codes using Ente Auth plain text exports.

Syntax:
  ${0##*/} ~/Downloads/ente-auth-codes-YYYY-mm-DD.txt
EOF
}

main() {
    if [[ $# -ne 1 ]]; then
        usage
        exit
    fi

    timedatectl --adjust-system-clock

    while true; do
        epoch_current="$(date +%s)"
        seconds_current="$((epoch_current % 60))"

        if [ "${seconds_current}" -lt 30 ]; then
            seconds_next="$((30 - seconds_current))"
            epoch_next="$((epoch_current + seconds_next))"
        else
            seconds_next="$((60 - seconds_current))"
            epoch_next="$((epoch_current + seconds_next))"
        fi

        printf '\033[H\033[J'

        sed --quiet 's#^[^:]*:[^:]*:\([^?]*\)?.*&secret=\([^&]*\)&codeDisplay=.*#\1 \2#p' "${1:?}" | while read -r account_name secret_key; do
            totp_current="$(printf '%s\n' "${secret_key}" | xargs oathtool --base32 --totp=SHA1 --time-step-size=30)"
            totp_next="$(printf '%s\n' "${secret_key}" | xargs oathtool  --base32 --totp=SHA1 --time-step-size=30 --now="@${epoch_next}")"
            printf '%s %s %s\n' "${account_name}" "${totp_current}" "${totp_next}"
        done | column -t -N ACCOUNT,CURRENT,NEXT

        printf "\n"
        while [ "$seconds_next" -gt 0 ]; do
            printf '\rRefreshing TOTPs in: %2ds' "${seconds_next}"
            sleep 1.0
            seconds_next=$((seconds_next - 1))
        done
    done
}

# begin script from here
main "${@}"













# function totp () {
#     if [[ $# -ne 2 ]]; then
#         builtin command awk -F '\?secret=' '{print $1}' "${1:?}" | builtin command sed 's|otpauth://totp/||g'
#         builtin printf '\n%s\n' 'usage: totp <file> <account>' && return
#     else
#         builtin command grep --ignore-case "${2:?}" "${1:?}" \
#             | awk -F '\?secret=' '{print $2}' \
#             | xargs oathtool --base32 --totp=SHA1 --time-step-size=30 \
#             | tee /dev/stderr \
#             | xclip -selection clipboard
#     fi
# }
# TOTP | tee /dev/stderr | xclip -selection clipboard
