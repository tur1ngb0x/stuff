#!/usr/bin/env bash

#/usr/bin/curl -4 -s 'https://api.github.com/repos/ryanoasis/nerd-fonts/contents/patched-fonts?ref=master' | /usr/bin/jq -r '.[] | select(.type=="dir") | .name' | /usr/bin/sed "s/.*/'\&'/" | LC_ALL=C /usr/bin/sort

readonly fonts=(
    '0xProto'
    '3270'
    'AdwaitaMono'
    'Agave'
    'AnonymousPro'
    'Arimo'
    'AtkinsonHyperlegibleMono'
    'AurulentSansMono'
    'BigBlueTerminal'
    'BitstreamVeraSansMono'
    'CascadiaCode'
    'CascadiaMono'
    'CodeNewRoman'
    'ComicShannsMono'
    'CommitMono'
    'Cousine'
    'D2Coding'
    'DaddyTimeMono'
    'DejaVuSansMono'
    'DepartureMono'
    'DroidSansMono'
    'EnvyCodeR'
    'FantasqueSansMono'
    'FiraCode'
    'FiraMono'
    'GeistMono'
    'Go-Mono'
    'Gohu'
    'Hack'
    'Hasklig'
    'HeavyData'
    'Hermit'
    'IBMPlexMono'
    'Inconsolata'
    'InconsolataGo'
    'InconsolataLGC'
    'IntelOneMono'
    'Iosevka'
    'IosevkaTerm'
    'IosevkaTermSlab'
    'JetBrainsMono'
    'Lekton'
    'LiberationMono'
    'Lilex'
    'MPlus'
    'MartianMono'
    'Meslo'
    'Monaspace'
    'Monofur'
    'Monoid'
    'Mononoki'
    'NerdFontsSymbolsOnly'
    'Noto'
    'OpenDyslexic'
    'Overpass'
    'ProFont'
    'ProggyClean'
    'Recursive'
    'RobotoMono'
    'ShareTechMono'
    'SourceCodePro'
    'SpaceMono'
    'Terminus'
    'Tinos'
    'Ubuntu'
    'UbuntuMono'
    'UbuntuSans'
    'VictorMono'
    'ZedMono'
    'iA-Writer'
)

usage() {
    local symbol="(I)"
    local font_dir="${HOME}/.local/share/fonts"
    local width="$((/usr/bin/tput cols 2>/dev/null) || builtin echo 80)"

    /usr/bin/tput rev
    builtin echo "Available: https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts"
    /usr/bin/tput sgr0

    for i in "${!fonts[@]}"; do
        local font_name="${fonts[$i]}"
        local installed=""

        [[ -d "${font_dir}/${font_name}" ]] && installed="${symbol}"

        builtin printf "[%02d] %s%s\n" "$((i + 1))" "${installed}" "${font_name}"
    done | /usr/bin/column -c "${width}"

    /usr/bin/tput rev
    builtin echo "Usage: ${0##*/} <index>"
    /usr/bin/tput sgr0
}

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

# this showed (index-1), one number less than selected option
# arguments() {
#     if [[ ! "$1" =~ ^[0-9]+$ ]]; then
#         usage
#         exit 1
#     fi
#
#     local idx=$(( $1 - 1 ))
#
#     if [[ $idx -lt 0 || $idx -ge ${#fonts[@]} ]]; then
#         echo "Error: Index '$1' is out of range (Available: 1-${#fonts[@]})"
#         exit 1
#     fi
#
#     font="${fonts[$idx]}"
#     tput rev; echo "Selected: [${idx}] ${font}"; tput sgr0
# }

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
