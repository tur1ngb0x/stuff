#!/usr/bin/env bash

set -euo pipefail
LC_ALL=C

show() { (
	set -x
	"${@:?}"
); }
header() {
	tput bold
	tput setaf 4
	printf "%s\n" "${1}"
	tput sgr0
}
#error () { tput bold; tput setaf 1; printf "Error - "; tput sgr0; printf "%s\n" "${1}"; tput sgr0; }
text() {
	tput setaf 2
	printf "%s \n" "${1}"
	tput sgr0
}
error() {
	tput setaf 1
	printf "%s \n" "${1}"
	tput sgr0
}

show_usage() {
	header 'Syntax'
	cat <<EOF
$ nerdfont.sh 'font'
$ nerdfont.sh 'font1' 'font2' 'font3' ... 'fontN'
EOF

	header 'Example'
	cat <<EOF
$ nerdfont.sh 'CascadiaMono'
$ nerdfont.sh 'AdwaitaMono' 'NerdFontsSymbolsOnly' 'ZedMono'
EOF
}

ensure_reqs() {
	# create cache dir
	mkdir -p /tmp/nerdfont.sh

	# detect missing commands
	missing_cmds=""
	for cmd; do
		if ! command -v "${cmd}" >/dev/null 2>&1; then
			missing_cmds="${missing_cmds}${cmd} "
		fi
	done
	# exit if requirements fail
	if [ -n "${missing_cmds}" ]; then
		error "missing - ${missing_cmds}"
		exit 1
	fi
}

show_fonts_local() {
	header "Installed Fonts (file:///home/${USER}/.local/share/fonts/)"

	# get all font folder names
	find "${HOME}/.local/share/fonts" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort | column
}

show_fonts_remote() {
	header "Available Fonts (https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/)"

	# if cached file is (absent OR empty OR stale) download a fresh copy from github
	if [ ! -f /tmp/nerdfont.sh/fonts-remote ] || [ ! -s /tmp/nerdfont.sh/fonts-remote ] || [ ! -z "$(find /tmp/nerdfont.sh/fonts-remote -maxdepth 1 -type f -mmin +60 2>/dev/null)" ]; then
		curl -4sfL "https://api.github.com/repos/ryanoasis/nerd-fonts/contents/patched-fonts" >/tmp/nerdfont.sh/fonts-remote-tmp
	fi

	# extract name key from folders
	jq -r '.[] | select(.type=="dir") | .name' /tmp/nerdfont.sh/fonts-remote-tmp >/tmp/nerdfont.sh/fonts-remote

	# sort folders and format as columns
	sort /tmp/nerdfont.sh/fonts-remote | column
}

install_fonts() {
	# get font names
	input_fonts=("$@")

	# remove duplicate font names
	set -- "$(printf '%s\n' "$@" | sed 's/\r$//' | awk '!seen[$0]++')"

	# update font names
	input_fonts=("$@")

	# count font names
	total_fonts=$#
	i=0

	# ensure cache dir exists
	show mkdir -p /tmp/nerdfont.sh

	for font in "${input_fonts[@]}"; do
		i=$((i + 1))
		text "Installing Nerd Font (${i}/${total_fonts}) - ${font}"

		# check if font name is valid
		if ! grep -Fxq "${font}" /tmp/fonts-remote-sort 2>/dev/null; then
			error "'${font}' is an invalid font name."
			continue
		fi

		# check if font is already installed
		if [ -d "${HOME}/.local/share/fonts/${font}" ]; then
			error "'${font}' is already installed."
			continue
		fi

		# if archive not present, download it; if present, reuse it
		if [ -s "/tmp/nerdfont.sh/${font}.tar.xz" ]; then
			error "'${font}' is already downloaded."
		else
			show curl -4sfL -o "/tmp/nerdfont.sh/${font}.tar.xz" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.tar.xz"
		fi

		# install font from archive
		show mkdir -p "${HOME}/.local/share/fonts/${font}"

		# extract only NerdFontMono variant
		show tar --file "/tmp/nerdfont.sh/${font}.tar.xz" --extract --xz --directory "${HOME}/.local/share/fonts/${font}" --wildcards '*NerdFontMono*'
	done

	# set correct font permissions
	text 'Setting Font Permissions'
	show sudo chown -R "${USER}:${USER}" "${HOME}/.local/share/fonts"

	# regenerate font cache
	text 'Regenerating Font Cache'
	show fc-cache -r
}

main() {
	ensure_reqs find curl awk grep sed sort tar fc-cache

	show_fonts_local
	show_fonts_remote

	if [ $# -eq 0 ]; then
		show_usage
		exit 1
	fi

	install_fonts "${@}"
}

# begin script from here
main "${@}"

# PatchFonts() {
#     stock_fonts=${1}
#     patched_fonts=${2}
#     mkdir -p "${stock_fonts}" "${patched_fonts}"
#     docker --debug --log-level 'debug' container run --rm \
#         --volume "${stock_fonts}":/in:Z \
#         --volume "${patched_fonts}":/out:Z \
#         --env "PN=4" \
#         nerdfonts/patcher \
#             --debug 3 \
#             --complete \
#             --mono \
#             --single-width-glyphs \
#             --removeligs \
#             --adjust-line-height \
#             --progressbars
#     sudo chown -R "${USER}:${USER}" "${patched_fonts}"
# }
