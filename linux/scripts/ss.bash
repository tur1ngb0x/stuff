#!/usr/bin/env bash

set -euo pipefail

readonly NOTIFY="/usr/bin/notify-send"
readonly SCROT="/usr/bin/scrot"
readonly XCLIP="/usr/bin/xclip"
readonly SLURP="/usr/bin/slurp"
readonly GRIM="/usr/bin/grim"
readonly WLCOPY="/usr/bin/wl-copy"
readonly DATE="/usr/bin/date"

notify() {
    printf '[%s] %s\n' "${0##*/}" "${*}" >&2
    "${NOTIFY}" -t 1000 "[${0##*/}]" "${*}" >/dev/null 2>&1 || :
}

require() {
    local cmd missing=()

    for cmd in "${@}"; do
        [[ -x "${cmd}" ]] || missing+=("${cmd}")
    done

    if ((${#missing[@]} > 0)); then
        notify "missing dependencies: ${missing[*]}"
        exit 1
    fi
}

save() {
    printf '%s/%s_%s.png\n' \
        "${HOME}/Pictures" \
        "${0##*/}" \
        "$("${DATE}" +%Y%m%d-%H%M%S)"
}

ss_x11() {
    require "${SCROT}" "${XCLIP}"

    local file
    file="$(save)"

    "${SCROT}" -s -f -q 100 -Z 0 -o "${file}"
    "${XCLIP}" -selection clipboard -t image/png -i "${file}"

    notify "saved to clipboard and disk"
}

ss_wayland() {
    require "${SLURP}" "${GRIM}" "${WLCOPY}"

    local file
    file="$(save)"

    "${SLURP}" -d | "${GRIM}" -l 0 -g - "${file}"
    "${WLCOPY}" < "${file}"

    notify "saved to clipboard and disk"
}

main() {
    if [[ "${#}" -ne 0 ]]; then
        printf 'usage: %s\n' "${0##*/}" >&2
        exit 1
    fi

    { builtin set -x ;} &> /dev/null
    case "${XDG_SESSION_TYPE:-}" in
        x11) ss_x11 ;;
        wayland) ss_wayland ;;
        *) notify "unsupported session: ${XDG_SESSION_TYPE:-unknown}"; exit 1 ;;
    esac
    { builtin set +x ;} &> /dev/null
}

main "${@}"
