#!/usr/bin/env bash

usage() {
    printf 'usage: editcfg <app> [scope]\n'
    printf 'apps: profile xprofile bash git alacritty\n'
    printf 'scope: system | user\n'
}

app="${1}"
scope="${2:-user}"
cfg=""

[[ -z "${app}" ]] && {
    usage
    exit 1
}

# editor policy (script-local)
VISUAL="micro"
EDITOR="micro"
export VISUAL EDITOR

case "${app}:${scope}" in
    profile:user)      cfg="${HOME}/.profile" ;;
    profile:system)    cfg="/etc/profile" ;;

    xprofile:user)     cfg="${HOME}/.xprofile" ;;
    xprofile:system)   cfg="/etc/X11/xprofile" ;;

    bash:user)         cfg="${HOME}/.bashrc" ;;
    bash:system)       cfg="/etc/bash.bashrc" ;;

    git:user)          cfg="${HOME}/.config/git/config" ;;
    git:system)        cfg="/etc/gitconfig" ;;

    alacritty:user)    cfg="${HOME}/.config/alacritty/alacritty.toml" ;;
    alacritty:system)  cfg="/etc/alacritty/alacritty.toml" ;;

    *) {
        printf 'editcfg: invalid app or scope: %s %s\n' "${app}" "${scope}"
        usage
        exit 1
    } ;;
esac

[[ -e "${cfg}" ]] || {
    printf 'editcfg: config not found: %s\n' "${cfg}"
    exit 1
}

case "${scope}" in
    user) micro "${cfg}" ;;
    system) sudoedit "${cfg}" ;;
esac
