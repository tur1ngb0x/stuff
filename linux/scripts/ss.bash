#!/usr/bin/env bash

notify() {
    local msg="$*"
    builtin printf '[%s] %s - %s\n' "${0##*/}" "${XDG_SESSION_TYPE}" "${msg}" >&2
    builtin command notify-send -t 1000 "[${0##*/}]" "${XDG_SESSION_TYPE} - ${msg}"
}

check() {
    local missing=()
    for name in "${@}"; do if ! builtin command -v "${name}" >/dev/null 2>&1; then missing+=("${name}"); fi; done
    if (( ${#missing[@]} > 0 )); then notify "${missing[*]} not found in PATH"; builtin exit 1; fi
}

ss_x11(){
    check scrot xclip \
    && builtin command scrot -s -f -q 100 -Z 0 -o /tmp/ss.png 2>/dev/null \
    && builtin command xclip -sel clip -t image/png -i /tmp/ss.png \
    && builtin command install -D -o "${USER}" -g "${USER}" -m 755 /tmp/ss.png "${HOME}/Pictures/${0##*/}_$(builtin command date +%Y%m%d-%H%M%S).png" \
    && notify 'saved to clipboard and disk' \
    && builtin exit 0
}

ss_wayland(){
    check slurp grim wl-copy \
    && builtin command slurp -d | builtin command grim -l 0 -g - /tmp/ss.png \
    && builtin command wl-copy < /tmp/ss.png \
    && builtin command install -v -D -o "${USER}" -g "${USER}" -m 755 /tmp/ss.png "${HOME}/Pictures/${0##*/}_$(builtin command date +%Y%m%d-%H%M%S).png" \
    && notify 'saved to clipboard and disk' \
    && builtin exit 0
}

main() {
    if [[ $# -ne 0 ]]; then
        builtin printf 'usage: %s\n' "${0##*/}"
        builtin exit 1
    fi

    if [[ "${XDG_SESSION_TYPE:-}" == 'x11' ]]; then
        ss_x11
    elif [[ "${XDG_SESSION_TYPE:-}" == 'wayland' ]]; then
        ss_wayland
    else
        notify 'Cannot determine XDG_SESSION_TYPE'
        builtin exit 1
    fi
}

main "${@}"


ss_minimal(){
    scrot -s -f -q 100 -Z 0 -o /tmp/ss.png \
        && xclip -sel clip -t image/png -i /tmp/ss.png \
            && install -D /tmp/ss.png "${HOME}/Pictures/${0##*/}_$(date +%Y%m%d-%H%M%S).png" \
                && notify-send -t 2500 "[${0##*/}]" "screenshot saved to clipboard and disk"
}

ss_i3wm() {
    # for i3wm, scrot has issues with $mod/Mod4 Key
    # use bindsym --release
    # bindsym --release $SUPER+$SHIFT+s exec --no-startup-id ~/src/scripts/ss.sh
    true
}

ss_gnome(){
    gsettings reset org.gnome.shell.keybindings show-screenshot-ui
    gsettings set org.gnome.shell.keybindings show-screenshot-ui "[]"
    gsettings set org.gnome.shell.keybindings show-screenshot-ui "['Print', '<Super><Shift>S']"
}

ss_gradia(){
    # flatpak install --user be.alexandervanhee.gradia
    gsettings reset org.gnome.shell.keybindings show-screenshot-ui
    gsettings set org.gnome.shell.keybindings show-screenshot-ui "[]"
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
        "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ \
        name 'Gradia Screenshot'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ \
        command 'flatpak run be.alexandervanhee.gradia --screenshot=INTERACTIVE'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ \
        binding '<Super><Shift>S'
}
