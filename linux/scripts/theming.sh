#!/usr/bin/env bash

git clone https://gitlab.gnome.org/GNOME/adwaita-fonts.git /usr/share/fonts/gitlab.gnome.org_GNOME_adwaita-fonts

wget -4O adwaita-fonts.tar.gz https://gitlab.gnome.org/GNOME/adwaita-fonts/-/archive/main/adwaita-fonts-main.tar.gz

tar -xzf adwaita-fonts.tar.gz

/usr/bin/sudo /usr/bin/mkdir -p /usr/share/fonts/adwaita-fonts-gitlab

# font
/usr/bin/wget -qO- https://gitlab.gnome.org/GNOME/adwaita-fonts/-/archive/main/adwaita-fonts-main.tar.gz \
    | /usr/bin/sudo /usr/bin/tar -xzf - \
        --strip-components=1 \
        -C /usr/share/fonts/adwaita-fonts-gitlab \
        adwaita-fonts-main/mono \
        adwaita-fonts-main/sans

/usr/bin/sudo /usr/bin/mkdir -p /usr/share/fonts/iosevka-fonts-nerd

curl -s 'https://api.github.com/repos/be5invis/Iosevka/releases/latest' \
    | jq -r '.assets[].browser_download_url' \
    | sort -u \
    | grep -E 'SuperTTC-SGr-IosevkaFixed-.*\.zip$' \
    | xargs -n1 -I{} sh -c '
        tmp=$(mktemp)
        curl -fsSL "{}" -o "$tmp"
        sudo mkdir -p /usr/share/fonts/iosevka-fonts-nerd
        sudo unzip -oq "$tmp" -d /usr/share/fonts/iosevka-fonts-nerd
        rm -f "$tmp"
    '

# icons
/usr/bin/wget -qO- https://git.io/papirus-icon-theme-install | /usr/bin/sh
/usr/bin/wget -qO- https://git.io/papirus-folders-install | /usr/bin/sh

