
gsettings_tracker() {
    gsettings set org.freedesktop.Tracker3.Miner.Files index-single-directories "[]"
    gsettings set org.freedesktop.Tracker3.Miner.Files index-recursive-directories "[]"
}

gsettings_desktop() {
    gsettings set org.gnome.desktop.interface clock-format '24h'
    gsettings set org.gnome.desktop.interface clock-show-date true
    gsettings set org.gnome.desktop.interface clock-show-seconds true
    gsettings set org.gnome.desktop.interface clock-show-weekday true
    gsettings set org.gnome.desktop.interface show-battery-percentage true
    gsettings set org.gnome.desktop.wm.preferences num-workspaces 5
}

gsettings_mutter() {
    gsettings set org.gnome.mutter center-new-windows true
    gsettings set org.gnome.mutter dynamic-workspaces false
}

gsettings_shell() {
    gsettings set org.gnome.shell favorite-apps "[]"
    gsettings set org.gnome.shell welcome-dialog-last-shown-version '999.0'
    gsettings set org.gnome.shell disable-user-extensions true
    for i in $(gnome-extensions list); do gnome-extensions disable "${i}"; done
}

gsettings_nightlight() {
    gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
    gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false
    gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 18.0
    gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 6.0
    gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 2500
}

gsettings_power() {
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'suspend'
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 600
    gsettings set org.gnome.desktop.session idle-delay 0
    gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
    gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'nothing'
}

gsettings_font() {
    gsettings set org.gnome.desktop.interface font-name 'Adwaita Sans 10'
    gsettings set org.gnome.desktop.interface document-font-name 'Adwaita Sans 10'
    gsettings set org.gnome.desktop.interface monospace-font-name 'Adwaita Mono 10'
    gsettings set org.gnome.desktop.interface text-scaling-factor 1.0
    gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Adwaita Sans 10'
    gsettings set org.gnome.desktop.interface font-hinting 'full'
    gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'
    gsettings set org.gnome.desktop.interface font-rgba-order 'rgb'
}

gsettings_theme() {
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
    gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
    gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
    gsettings set org.gnome.desktop.sound theme-name 'freedesktop'
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
}

gsettings_ptyxis() {
    gsettings set org.gnome.Ptyxis use-system-font false
    gsettings set org.gnome.Ptyxis font-name 'Iosevka Fixed Expanded 14'
    gsettings set org.gnome.Ptyxis text-blink-mode 'focused'
    gsettings set org.gnome.Ptyxis cursor-shape 'underline'
    gsettings set org.gnome.Ptyxis cursor-blink-mode 'on'
    gsettings set org.gnome.Ptyxis interface-style 'light'
}

gnome-shell --version
printf "Reset dconf before applying settings? (Y/n): " && read -r ans && [[ "${ans}" =~ ^[Yy]$ ]] && dconf reset -f /
gsettings_desktop
gsettings_font
gsettings_mutter
gsettings_nightlight
gsettings_power
gsettings_shell
gsettings_theme
gsettings_tracker
gsettings_ptyxis
