#!/usr/bin/env bash

notify() {
    local msg="$*"

    builtin printf '[%s] %s - %s\n' \
        "${0##*/}" \
        "${XDG_SESSION_TYPE}" \
        "${msg}" \
        >&2

    /usr/bin/notify-send \
        -t 1000 \
        "[${0##*/}]" \
        "${XDG_SESSION_TYPE} - ${msg}"
}

check() {
    local missing=()

    for name in "${@}"; do
        [[ -x "/usr/bin/${name}" ]] || missing+=("${name}")
    done

    if (( ${#missing[@]} > 0 )); then
        notify "${missing[*]} not found in PATH"
        builtin exit 1
    fi
}

ss_x11(){
    check scrot xclip \
    && /usr/bin/scrot -s -f -q 100 -Z 0 -o /tmp/ss.png 2>/dev/null \
    && /usr/bin/xclip -sel clip -t image/png -i /tmp/ss.png \
    && /usr/bin/install \
        -D \
        -o "${USER}" \
        -g "${USER}" \
        -m 755 \
        /tmp/ss.png \
        "${HOME}/Pictures/${0##*/}_$(/usr/bin/date +%Y%m%d-%H%M%S).png" \
    && notify 'saved to clipboard and disk' \
    && builtin exit 0
}

ss_wayland(){
    check slurp grim wl-copy \
    && /usr/bin/slurp -d | /usr/bin/grim -l 0 -g - /tmp/ss.png \
    && /usr/bin/wl-copy < /tmp/ss.png \
    && /usr/bin/install \
        -v \
        -D \
        -o "${USER}" \
        -g "${USER}" \
        -m 755 \
        /tmp/ss.png \
        "${HOME}/Pictures/${0##*/}_$(/usr/bin/date +%Y%m%d-%H%M%S).png" \
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
    /usr/bin/scrot -s -f -q 100 -Z 0 -o /tmp/ss.png \
        && /usr/bin/xclip -sel clip -t image/png -i /tmp/ss.png \
            && /usr/bin/install -D /tmp/ss.png "${HOME}/Pictures/${0##*/}_$(/usr/bin/date +%Y%m%d-%H%M%S).png" \
                && /usr/bin/notify-send -t 2500 "[${0##*/}]" "screenshot saved to clipboard and disk"
}

ss_i3wm() {
    # for i3wm, scrot has issues with $mod/Mod4 Key
    # use bindsym --release
    # bindsym --release $SUPER+$SHIFT+s exec --no-startup-id ~/src/scripts/ss.sh
    true
}

ss_gnome(){
    /usr/bin/gsettings reset org.gnome.shell.keybindings show-screenshot-ui

    /usr/bin/gsettings set \
        org.gnome.shell.keybindings \
        show-screenshot-ui \
        "[]"

    /usr/bin/gsettings set \
        org.gnome.shell.keybindings \
        show-screenshot-ui \
        "['Print', '<Super><Shift>S']"
}

ss_gradia(){
    # flatpak install --user be.alexandervanhee.gradia

    /usr/bin/gsettings reset \
        org.gnome.shell.keybindings \
        show-screenshot-ui

    /usr/bin/gsettings set \
        org.gnome.shell.keybindings \
        show-screenshot-ui \
        "[]"

    /usr/bin/gsettings set \
        org.gnome.settings-daemon.plugins.media-keys \
        custom-keybindings \
        "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"

    /usr/bin/gsettings set \
        org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ \
        name \
        'Gradia Screenshot'

    /usr/bin/gsettings set \
        org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ \
        command \
        'flatpak run be.alexandervanhee.gradia --screenshot=INTERACTIVE'

    /usr/bin/gsettings set \
        org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ \
        binding \
        '<Super><Shift>S'
}
