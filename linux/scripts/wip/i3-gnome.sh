#!/usr/bin/env bash



reset_settings(){
    echo "Resetting settings"
    for i in {1..9}; do gsettings set org.gnome.desktop.wm.keybindings "move-to-workspace-${i}" "[]"; done
    for i in {1..9}; do gsettings set org.gnome.desktop.wm.keybindings "switch-to-workspace-${i}" "[]"; done
    for i in {1..9}; do gsettings set org.gnome.shell.keybindings "switch-to-application-${i}" "[]"; done
    gsettings reset org.gnome.desktop.wm.preferences num-workspaces
    gsettings reset org.gnome.mutter dynamic-workspaces
    gsettings reset org.gnome.shell.app-switcher current-workspace-only
    gsettings set org.gnome.desktop.wm.keybindings close "[]"
    gsettings set org.gnome.desktop.wm.keybindings move-to-side-e "[]"
    gsettings set org.gnome.desktop.wm.keybindings move-to-side-n "[]"
    gsettings set org.gnome.desktop.wm.keybindings move-to-side-s "[]"
    gsettings set org.gnome.desktop.wm.keybindings move-to-side-w "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "[]"
}

apply_settings(){
    echo "Applying settings"
    for i in {1..9}; do gsettings set org.gnome.desktop.wm.keybindings "move-to-workspace-${i}" "['<super><shift>${i}']"; done
    for i in {1..9}; do gsettings set org.gnome.desktop.wm.keybindings "switch-to-workspace-${i}" "['<super>${i}']"; done
    gsettings set org.gnome.desktop.wm.keybindings close "['<super><shift>q']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<super><control>Left']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<super><control>Right']"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"
    gsettings set org.gnome.desktop.wm.preferences num-workspaces 5
    gsettings set org.gnome.mutter dynamic-workspaces false
    gsettings set org.gnome.shell.app-switcher current-workspace-only true
}

install_terminal(){
    local terminal="ptyxis"

    if command -v "${terminal}" &>/dev/null; then
        echo "${terminal} found"
    else
        echo "${terminal} not found"
        return
    fi

    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
    "[
        '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-super-enter/',
        '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-super-t/',
        '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-ctrl-alt-t/'
    ]"

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-super-enter/ name "${terminal}"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-super-enter/ command "${terminal}"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-super-enter/ binding '<Super>Return'

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-super-t/ name "${terminal}"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-super-t/ command "${terminal}"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-super-t/ binding '<Super>t'

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-ctrl-alt-t/ name "${terminal}"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-ctrl-alt-t/ command "${terminal}"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${terminal}-ctrl-alt-t/ binding '<Control><Alt>t'
}

printf "Reset dconf before i3-gnome? (Y/n): " && read -r ans && [[ "${ans}" =~ ^[Yy]$ ]] && dconf reset -f /
reset_settings
apply_settings
install_terminal
