#!/usr/bin/env bash

builtin unset -f "$(builtin compgen -A function)"
builtin unalias -a
export LC_ALL='C'
export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
set -euo pipefail

function show () {
    printf '\033[7m # %s | %s \033[0m\n' "$(date '+%Y-%m-%d %H:%M:%S')" "${*}"
    eval "${@:?}"
}

function check () {
    command -v "${1:?}" &>/dev/null
}

function cleanup () {
    unset -f show
    unset -f check
    unset -v ELEVATE
    exit
}

if [[ "$(id -ur)" -ne 0 ]]; then
    ELEVATE="sudo"
fi

check am      && show "bash -c 'am sync && am update'"
check code    && show "bash -c 'code --update-extensions'"
check pipx    && show "bash -c 'pipx upgrade-all'"
check flatpak && show "bash -c 'flatpak update --noninteractive'"
check snap    && show "${ELEVATE:-} bash -c 'snap refresh'"

check apt-get && show "${ELEVATE:-} bash -c 'apt-get update && apt-get dist-upgrade'" && cleanup
check dnf     && show "${ELEVATE:-} bash -c 'dnf upgrade --refresh'"                  && cleanup
check pacman  && show "${ELEVATE:-} bash -c 'pacman -Syyu --needed'"                  && cleanup
# check pamac   && show "${ELEVATE:-} bash -c 'pamac upgrade --refresh'"                && cleanup

# cleanup
cleanup
