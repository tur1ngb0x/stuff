#!/usr/bin/env bash

builtin set -euo pipefail
export LC_ALL=C
export PATH='/usr/local/sbin:/usr/local/bin:/usr/bin'

function show () {
    builtin printf '\033[7m # %s | $ %s \033[0m\n' "$(command date '+%Y-%m-%d %H:%M:%S')" "${*}"
    builtin eval "${@:?}"
}

function check () {
    command -v "${1:?}" &>/dev/null
}

function cleanup () {
	builtin unset -f show
	builtin unset -f check
	builtin unset -v ELEVATE
	builtin exit
}

if [[ "$(command id -ur)" -ne 0 ]]; then
    ELEVATE="command sudo"
fi

# third party
check code    && show "command code --update-extensions"
check pipx    && show "command pipx upgrade-all"
check flatpak && show "command flatpak update --noninteractive"
check snap    && show "${ELEVATE:-} snap refresh"

# first party
check apt-get && show "${ELEVATE:-} bash -c 'apt-get update && apt-get dist-upgrade'" && cleanup
check dnf     && show "${ELEVATE:-} bash -c 'dnf upgrade --refresh'"                  && cleanup
check pacman  && show "${ELEVATE:-} bash -c 'pacman -Syyu --needed'"                  && cleanup
# check pamac   && show "${ELEVATE:-} bash -c 'pamac upgrade --refresh'"               && cleanup

# cleanup
cleanup
