#!/usr/bin/env bash

LC_ALL=C
set -euxo pipefail

# download archive
command -p wget -4 -O /tmp/code.tar.gz "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64"

# create installation directory
command -p mkdir -v -p "${HOME}/.apps/code"

# extract archive
command -p tar -v -f /tmp/code.tar.gz -xz -C "${HOME}/.apps/code" --strip-components=1

# create portable directory
command -p mkdir -v -p "${HOME}/.apps/code/data/tmp"

# install binary
command -p mkdir -p "${HOME}/.local/bin
ln -v -s -v -r ${HOME}/.apps/code/bin/code "${HOME}/.local/bin/code

# install bash completion

# install desktop file for launcher
command -p mkdir -p "${HOME}/.local/share/applications"
command -p cat << EOF | command -p tee "${HOME}/.local/share/applications/code.desktop"
[Desktop Entry]
Name=Code (Portable)
Exec=${HOME}/.apps/code/bin/code %F
Icon=${HOME}/.apps/code/resources/app/resources/linux/code.png
Type=Application
StartupNotify=false
StartupWMClass=Code
Categories=TextEditor;Development;IDE;
MimeType=application/x-code-workspace;
EOF

# install desktop file for handling urls
command -p mkdir -p "${HOME}/.local/share/applications"
command -p cat << EOF | ommand -p tee "${HOME}/.local/share/applications/code-url-handler.desktop"
[Desktop Entry]
Name=Code URL Handler (Portable)
Exec=${HOME}/.apps/code/bin/code --open-url %U
Icon=${HOME}/.apps/code/resources/app/resources/linux/code.png
Type=Application
NoDisplay=true
StartupNotify=true
Categories=Utility;TextEditor;Development;IDE;
MimeType=x-scheme-handler/vscode;
EOF
