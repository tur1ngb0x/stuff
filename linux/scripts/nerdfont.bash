#!/usr/bin/env bash

readonly fonts=(
0xProto
3270
AdwaitaMono
Agave
AnonymousPro
Arimo
AtkinsonHyperlegibleMono
AurulentSansMono
BigBlueTerminal
BitstreamVeraSansMono
CascadiaCode
CascadiaMono
CodeNewRoman
ComicShannsMono
CommitMono
Cousine
D2Coding
DaddyTimeMono
DejaVuSansMono
DepartureMono
DroidSansMono
EnvyCodeR
FantasqueSansMono
FiraCode
FiraMono
GeistMono
Go-Mono
Gohu
Hack
Hasklig
HeavyData
Hermit
IBMPlexMono
Inconsolata
InconsolataGo
InconsolataLGC
IntelOneMono
Iosevka
IosevkaTerm
IosevkaTermSlab
JetBrainsMono
Lekton
LiberationMono
Lilex
MPlus
MartianMono
Meslo
Monaspace
Monofur
Monoid
Mononoki
NerdFontsSymbolsOnly
Noto
OpenDyslexic
Overpass
ProFont
ProggyClean
Recursive
RobotoMono
ShareTechMono
SourceCodePro
SpaceMono
Terminus
Tinos
Ubuntu
UbuntuMono
UbuntuSans
VictorMono
ZedMono
iA-Writer
)

numbered_list() {
    local arr=("$@")
    local width

    width="$(tput cols 2>/dev/null || echo 80)"

    mapfile -t arr < <(printf '%s\n' "${arr[@]}" | LC_ALL=C sort)

    for i in "${!arr[@]}"; do
        printf "\033[38;2;128;128;128m[%02d]\033[0m %s\n" "$((i+1))" "${arr[i]}"
    done | column -c "${width}" -S1
}

show_installed() {

    mapfile -t installed_fonts < <(
        find "${HOME}/.local/share/fonts" \
        -mindepth 1 -maxdepth 1 \
        -type d -printf '%f\n' 2>/dev/null
    )

    tput rev; echo "Installed: ~/.local/share/fonts/"; tput sgr0
    numbered_list "${installed_fonts[@]}"
}

show_available() {
    tput rev; echo "Available: https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/"; tput sgr0
    numbered_list "${fonts[@]}"
}

usage() {

    show_installed
    show_available
    tput rev; echo "Usage:"; tput sgr0
    echo "# ${0##*/} <font-index>"
    echo "# ${0##*/} 52"
}

check_arguments() {

    if [[ $# -ne 1 ]] || ! [[ ${1} =~ ^[0-9]+$ ]]; then
        usage
        exit 1
    fi

    idx=$((10#${1} - 1))

    if (( idx < 0 || idx >= ${#fonts[@]} )); then
        usage
        exit 1
    fi

    font="${fonts[idx]}"
}

download_fonts() {

    echo "Installing ${font}"

    { set -x; } &>/dev/null

    wget -q -O "/tmp/${font}.tar.xz" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.tar.xz"

    mkdir -p "${HOME}/.local/share/fonts/${font}"

    tar -f "/tmp/${font}.tar.xz" -xJ \
        --wildcards --no-anchored --overwrite \
        -C "${HOME}/.local/share/fonts/${font}" \
        "*NerdFontMono-*"

    rm -rf "${HOME}/.cache/fontconfig"
    fc-cache --really-force

    { set +x; } &>/dev/null

    cat << EOF
Restart applications for the installed fonts to take effect.
EOF
}

main() {
    check_arguments "$@"
    download_fonts
}

main "$@"

# get font names
# /usr/bin/curl -4 -f -s -S -L 'https://api.github.com/repos/ryanoasis/nerd-fonts/contents/patched-fonts?ref=master' | jq -r '.[] | select(.type=="dir") | .name' | LC_ALL=C /usr/bin/sort
#
