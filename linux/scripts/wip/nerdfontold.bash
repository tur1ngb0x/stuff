#!/usr/bin/env bash

# curl -s 'https://api.github.com/repos/ryanoasis/nerd-fonts/contents/patched-fonts?ref=master' | jq -r '.[] | select(.type=="dir") | .name' | LC_ALL=C sort

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

usage() {
    cat << EOF
Available: https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts
$(width="$(tput cols 2>/dev/null || echo 80)"; printf '%s\n' "${fonts[@]}" | column -c "${width}" -S1)

Installed: ~/.local/share/fonts
$(find "${HOME}/.local/share/fonts/" -mindepth 1 -type f -iname "*nerd*" -printf '%h\n' 2>/dev/null | sort -u)

Usage:
${0##*/} <font>
EOF
}

arguments() {
    if [[ $# -ne 1 ]]; then
        usage
        exit 1
    fi

    local valid=1
    for f in "${fonts[@]}"; do
        if [[ "$1" == "$f" ]]; then
            valid=0
            break
        fi
    done

    if (( valid )); then
        usage
        exit 1
    fi

    font="$1"
}

download() {
    { set -x; } &>/dev/null

    wget -q -O "/tmp/${font}.tar.xz" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.tar.xz"

    mkdir -p "${HOME}/.local/share/fonts/${font}"

    tar -f "/tmp/${font}.tar.xz" -xJ \
        --wildcards --no-anchored --overwrite \
        -C "${HOME}/.local/share/fonts/${font}" \
        "*NerdFontMono-*"

    find "${HOME}/.cache/fontconfig" -mindepth 0 -maxdepth 0 -exec rm -rf -- {} + \
        && fc-cache --really-force

    { set +x; } &>/dev/null
}

main() {
    arguments "$@"
    download

    cat << EOF

You may need to close and re-open all applications
for the newly installed fonts to show up and take effect.

EOF
}

main "$@"
