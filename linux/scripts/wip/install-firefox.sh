LC_ALL=C
set -euxo pipefail


# download firefox
command -p wget -4 -O /tmp/firefox.tar.xz 'https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US'

# install firefox
command -p mkdir -v -p "${HOME}"/Apps
command -p tar -v -f /tmp/firefox.tar.xz -xJ -C "${HOME}"/Apps

# install cli launcher
command -p mkdir -pv "${HOME}"/.local/bin
command -p ln -v -s -f "${HOME}"/Apps/firefox/firefox "${HOME}"/.local/bin/firefox

# install desktop launcher
command -p mkdir -v -p "${HOME}"/.local/share/applications
wget -4 -O "${HOME}/.local/share/applications/firefox.desktop" 'https://raw.githubusercontent.com/mozilla/sumo-kb/main/install-firefox-linux/firefox.desktop'

sed -i \
    -e "s|Name=Firefox Web Browser|Name=Firefox (User)|g" \
    -e "s|Exec=firefox %u|Exec=${HOME}/Apps/firefox/firefox %u|g" \
    -e "s|Icon=/opt/firefox/browser/chrome/icons/default/default128.png|Icon=${HOME}/Apps/firefox/browser/chrome/icons/default/default128.png|g" \
"${HOME}/.local/share/applications/firefox.desktop"
