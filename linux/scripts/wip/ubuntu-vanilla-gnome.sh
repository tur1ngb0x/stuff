#!/usr/bin/env bash

# /usr/bin/bash --noprofile  --norc -c "$(/usr/bin/wget -4 -q -O- 'https://raw.githubusercontent.com/tur1ngb0x/stuff/refs/heads/main/linux/scripts/ubuntu-vanilla-gnome.sh')"

# /usr/bin/wget -4 -O '/tmp/ubuntu-vanilla-gnome.sh' 'https://raw.githubusercontent.com/tur1ngb0x/stuff/refs/heads/main/linux/scripts/ubuntu-vanilla-gnome.sh' && /usr/bin/chmod +x '/tmp/ubuntu-vanilla-gnome.sh' && '/tmp/ubuntu-vanilla-gnome.sh'

set -e

msg() {
    tput rev
    tput setaf 3
    tput bold
    echo " #### ${1^^} #### "
    tput sgr0
}

reset_gnome() {
    msg "settings"
    dconf reset -f /
    for i in $(gnome-extensions list | sort); do
        gnome-extensions disable "${i}"; done
}

install_packages(){
    msg "packages"

    sudo apt-get update

    sudo apt-get install -y \
        git \
        wget \
        curl \
        flatpak \
        alacritty

    sudo apt-get install --no-install-suggests --no-install-recommends -y \
        gnome-session \
        gnome-backgrounds \
        gnome-tweaks \
        vanilla-gnome-default-settings \
        gnome-shell-extension-manager

    flatpak --user remote-add "flathub-user-${USER}" \
        https://flathub.org/repo/flathub.flatpakrepo
}

install_fonts(){
    msg "fonts"

    sudo mkdir -p /usr/share/fonts/adwaita
    sudo git clone --depth=1 --single-branch --no-tags \
        https://gitlab.gnome.org/GNOME/adwaita-fonts.git \
        /usr/share/fonts/adwaita
    sudo fc-cache -r

    sudo mkdir -p /etc/fonts
    cat << 'EOF' | sudo tee /etc/fonts/local.conf
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <alias><family>serif</family><prefer><family>Adwaita Sans</family></prefer></alias>
    <alias><family>sans</family><prefer><family>Adwaita Sans</family></prefer></alias>
    <alias><family>sans-serif</family><prefer><family>Adwaita Sans</family></prefer></alias>
    <alias><family>mono</family><prefer><family>Adwaita Mono</family></prefer></alias>
    <alias><family>monospace</family><prefer><family>Adwaita Mono</family></prefer></alias>
</fontconfig>
EOF
    
    gsettings set org.gnome.desktop.interface font-name 'Adwaita Sans 10'
    gsettings set org.gnome.desktop.interface document-font-name 'Adwaita Sans 10'
    gsettings set org.gnome.desktop.interface monospace-font-name 'Adwaita Mono 10'
    gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Adwaita Sans Bold 10'

    gsettings set org.gnome.settings-daemon.plugins.xsettings hinting 'full'
    gsettings set org.gnome.settings-daemon.plugins.xsettings antialiasing 'rgba'
    gsettings set org.gnome.settings-daemon.plugins.xsettings rgba-order 'rgb'

    gsettings set org.gnome.desktop.interface text-scaling-factor 1.0
    gsettings set org.gnome.settings-daemon.plugins.xsettings dpi 96
}

install_wallpapers(){
    msg "wallpapers"

    gsettings set org.gnome.desktop.background picture-uri \
        'file:///usr/share/backgrounds/gnome/blobs-l.svg'
    gsettings set org.gnome.desktop.background picture-uri-dark \
        'file:///usr/share/backgrounds/gnome/blobs-l.svg'
}

install_terminal(){
    msg "terminal"

    local terminal="alacritty"

    command -v "$terminal" &>/dev/null || return

    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
    "[
        '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-super-enter/',
        '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-super-t/',
        '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-ctrl-alt-t/'
    ]"

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-super-enter/ name "$terminal"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-super-enter/ command "$terminal"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-super-enter/ binding '<Super>Return'

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-super-t/ name "$terminal"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-super-t/ command "$terminal"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-super-t/ binding '<Super>t'

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-ctrl-alt-t/ name "$terminal"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-ctrl-alt-t/ command "$terminal"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-ctrl-alt-t/ binding '<Control><Alt>t'
}

install_icons() {
    msg "icons"

    wget -qO- https://git.io/papirus-icon-theme-install | sh
    wget -qO- https://git.io/papirus-folders-install | sh
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
}

install_themes() {
    msg "themes"

    sudo mkdir -p /usr/share/themes

    wget -O /tmp/adw-gtk3.tar.xz \
        https://github.com/lassekongo83/adw-gtk3/releases/download/v6.4/adw-gtk3v6.4.tar.xz
    sudo tar -xf /tmp/adw-gtk3.tar.xz -C /usr/share/themes/

    flatpak --user install --runtime -y "flathub-user-${USER}" org.gtk.Gtk3theme.adw-gtk3
    flatpak --user install --runtime -y "flathub-user-${USER}" org.gtk.Gtk3theme.adw-gtk3-dark

    sudo update-alternatives --set gdm-theme.gresource \
        /usr/share/gnome-shell/gnome-shell-theme.gresource

    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    gsettings set org.gnome.desktop.interface accent-color 'blue'
}

uninstall_packages(){
    msg "bloat"

    sudo apt-get remove -y \
        ubuntu-session \
        yaru-theme-gnome-shell \
        yaru-theme-gtk \
        yaru-theme-icon \
        yaru-theme-sound

    sudo apt-get remove -y \
        ubuntu-report \
        apport-gtk \
        snapd

    sudo mkdir -p /etc/apt/preferences.d/
    cat << EOF | tee /etc/apt/preferences.d/ubuntu-snap-disabled.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
}

# execution order
reset_gnome
install_packages
install_wallpapers
install_icons
install_themes
install_terminal
install_fonts
# uninstall_packages

msg "Reboot immediately"
msg "Select GNOME session at login screen"
