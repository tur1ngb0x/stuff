#!/usr/bin/env bash

# /usr/bin/curl -4 -s 'https://api.github.com/repos/ryanoasis/nerd-fonts/contents/patched-fonts?ref=master' | /usr/bin/jq -r '.[] | "\u0027" + .name + "\u0027"' | LC_ALL=C /usr/bin/sort -f

cache="${HOME}/.cache/nerdfont.cache"

[[ -f "${cache}" && $(find "${cache}" -mtime -1 2>/dev/null) ]] || { mkdir -p -- "${cache%/*}" && /usr/bin/curl -4 -fsS 'https://api.github.com/repos/ryanoasis/nerd-fonts/contents/patched-fonts?ref=master' >| "${cache}"; }

mapfile -t fonts < <(/usr/bin/jq -r '.[].name' "${cache}" | LC_ALL=C /usr/bin/sort -f)

readonly -a fonts

usage() {
    local font_dir="${HOME}/.local/share/fonts"
    local width="$((/usr/bin/tput cols 2>/dev/null) || builtin echo 80)"

    builtin echo "Available: https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts"

    for i in "${!fonts[@]}"; do
        local font_name="${fonts[$i]}"

        if [[ -d "${font_dir}/${font_name}" ]]; then
            builtin printf '\033[7m[%02d] %s\033[0m\n' "$((i + 1))" "${font_name}"
        else
            builtin printf '[%02d] %s\n' "$((i + 1))" "${font_name}"
        fi
    done | /usr/bin/column -c "${width}"

    builtin echo "Usage: ${0##*/} <index>"
}

arguments() {
    if [[ ! "$1" =~ ^[0-9]+$ ]]; then
        usage
        builtin exit 1
    fi

    local idx=$(( $1 - 1 ))

    if [[ $idx -lt 0 || $idx -ge ${#fonts[@]} ]]; then
        builtin echo "Error: Invalid Input. Available 1-${#fonts[@]}"
        builtin exit 1
    fi

    font="${fonts[$idx]}"

    /usr/bin/tput rev
    builtin echo "Selected: [$1] ${font}"
    /usr/bin/tput sgr0
}

download() {
    { builtin set -x; } &>/dev/null

    /usr/bin/wget \
        -4 \
        -q \
        --hsts-file /tmp/wget-hsts \
        -O "/tmp/${font}.tar.xz" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.tar.xz"

    /usr/bin/mkdir -p "${HOME}/.local/share/fonts/${font}"

    /usr/bin/tar \
        -f "/tmp/${font}.tar.xz" \
        -xJ \
        --no-anchored \
        --overwrite \
        -C "${HOME}/.local/share/fonts/${font}"

    /usr/bin/find \
        "${HOME}/.cache/fontconfig" \
        -mindepth 0 \
        -maxdepth 0 \
        -type d \
        -exec /usr/bin/rm -rf -- {} +

    /usr/bin/fc-cache --really-force

    { builtin set +x; } &>/dev/null

    /usr/bin/tput rev
    builtin echo "Successfully installed ${HOME}/.local/share/fonts/${font}"
    /usr/bin/tput sgr0

    builtin echo "You may need to close and re-open all applications"
    builtin echo "for the newly installed fonts to show up and take effect."
}

main() {
    [[ $# -ne 1 ]] && usage && builtin exit 1

    arguments "$@"
    download
}

main "$@"

# repo='https://github.com/ryanoasis/nerd-fonts'

# [[ $# -eq 1 ]] || {
#     builtin printf 'Usage: %s <fontname>\n' "${0##*/}"
#     builtin printf 'Available: %s/tree/master/patched-fonts\n' "${repo}"
#     installed="$(/usr/bin/find "${HOME}/.local/share/fonts" -mindepth 1 -maxdepth 1 -type d -printf "'%f' " 2>/dev/null)"
#     builtin printf 'Installed: %s\n' "${installed:--}"
#     builtin exit 1
# }

# font="${1:?}"
# source="${repo}/releases/latest/download/${font}.tar.xz"
# file="/tmp/${font}.tar.xz"
# target="${HOME}/.local/share/fonts/${font}"

# /usr/bin/wget -4 -q --hsts-file /tmp/wget-hsts -O "${file}" "${source}"
# /usr/bin/mkdir -p "${target}"
# /usr/bin/tar -f "${file}" -xJ --overwrite -C "${target}"

