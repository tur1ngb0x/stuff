#!/usr/bin/env bash

# get font names
# curl -fsSL 'https://api.github.com/repos/ryanoasis/nerd-fonts/contents/patched-fonts?ref=master' | jq -r '.[] | select(.type=="dir") | .name'

# hard code font names
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

# check for invalid status
if [[ $# -ne 1 ]]; then
    invalid=1
else
    invalid=1
    for f in "${fonts[@]}"; do
        if [[ ${1} == "${f}" ]]; then
            invalid=0
            break
        fi
    done
fi

# show usage if invalid
if (( invalid )); then
    cat << EOF
Installed:
$(find /usr/share/fonts "${HOME}/.local/share/fonts/" -mindepth 1 -type f -iname "*nerd*" -printf '%h\n' 2>/dev/null | sort -u)

Fonts:
https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/
$(width="$(tput cols 2>/dev/null || echo 80)"; printf '%s\n' "${fonts[@]}" | column -c "${width}" -S1)

Usage:
${0##*/} <font>
EOF
    exit 1
fi

# download and install fonts
{ set -x; } &>/dev/null
wget -q -O "/tmp/${1:?}.tar.xz" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${1:?}.tar.xz"

mkdir -p "${HOME}/.local/share/fonts/${1:?}"

tar -f "/tmp/${1:?}.tar.xz" -xJ \
    --wildcards --no-anchored --overwrite \
    -C "${HOME}/.local/share/fonts/${1:?}" \
    "*NerdFontMono-*"

find "${HOME}/.cache/fontconfig" -mindepth 0 -maxdepth 0 -exec rm -rf -- {} + && fc-cache --really-force
{ set +x; } &>/dev/null

# print message
cat << EOF

You may need to close and re-open all applications
for the newly installed fonts to show up and take effect.

EOF
