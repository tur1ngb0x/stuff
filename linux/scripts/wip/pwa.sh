#!/usr/bin/env bash

# exit if arguments are not equal to 4
if [ "$#" -ne 4 ]; then
    cat << EOF
Usage:
$ pwa.sh 'BrowserName' 'FileName' 'AppName' 'URL'

Options:
BrowserName - brave-browser-stable, google-chrome-stable, microsoft-edge-stable, vivaldi
FileName    - Name of the desktop entry in ~/.local/share/applications/
AppName     - Name of the PWA in applications menu
URL         - Web address to open in the PWA

Examples:
$ pwa.sh 'BrowserName'           'FileName' 'AppName'  'URL'
$ pwa.sh 'brave-browser-stable'  'whatsapp' 'WhatsApp' 'web.whatsapp.com'
$ pwa.sh 'google-chrome-stable'  'youtube'  'YouTube'  'youtube.com'
$ pwa.sh 'microsoft-edge-stable' 'reddit'   'Reddit'   'reddit.com'
$ pwa.sh 'vivaldi'               'spotify'  'Spotify'  'open.spotify.com'

Installed Apps:
$(find ~/.local/share/applications -name "*.desktop" | sort)
EOF
    exit 1
fi

if ! command -v "${1}" &>/dev/null; then
    echo "${1} is not installed on the system."
    exit 1
fi

# create user apps directory
install -v -d -m 0755 -o "${USER}" -g "${USER}" "${HOME}/.local/share/applications/"

# install desktop file - BrowserName_AppName.desktop
cat << EOF | tee "${HOME}/.local/share/applications/${1}_${2}.desktop"
[Desktop Entry]
Name=${3}
StartupWMClass=${3}
Exec=${1} --profile-directory=Default --app=https://${4}
Icon=applications-internet
Terminal=false
Type=Application
EOF
