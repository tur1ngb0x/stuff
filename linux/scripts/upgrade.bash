#!/usr/bin/env bash

[[ "${BASH_SOURCE[0]}" != "${0}" ]] && {
    builtin printf '%s\n' 'Do not source this script' >&2
    builtin exit 1
}

[[ ${EUID} -eq 0 ]] && {
    builtin printf '%s\n' 'Do not run as root' >&2
    builtin exit 1
}

[[ ! -t 1 ]] && {
    builtin printf '%s\n' 'No interactive terminal detected' >&2
    builtin exit 1
}

while IFS= read -r fn; do
    builtin unset -f "${fn}"
done < <(builtin compgen -A function)

builtin unalias -a

export LC_ALL='C'
export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

set -euo pipefail

function show () {
    builtin printf -- '\033[7m # %s | %s \033[0m\n' \
        "$(/usr/bin/date '+%Y-%m-%d %H:%M:%S')" \
        "${*}"

    builtin eval "${@:?}"
}

function check () {
    [[ -x "/usr/bin/${1:?}" ]]
}

function cleanup () {
    builtin unset -f show
    builtin unset -f check
    builtin unset -v ELEVATE
    builtin exit
}

if [[ "$(/usr/bin/id -ur)" -ne 0 ]]; then
    check 'sudo' && ELEVATE="/usr/bin/sudo" || cleanup
fi

show "${ELEVATE:-} -v"

check am      && show "/usr/bin/bash -c 'am sync && am update'"
check code    && show "/usr/bin/bash -c 'code --update-extensions'"
check pipx    && show "/usr/bin/bash -c 'pipx upgrade-all'"
check flatpak && show "/usr/bin/bash -c 'flatpak update'"
check snap    && show "${ELEVATE:-} /usr/bin/bash -c 'snap refresh'"

check apt-get && show "${ELEVATE:-} /usr/bin/bash -c '/usr/bin/apt-get update && /usr/bin/apt-get dist-upgrade'" && cleanup
check dnf     && show "${ELEVATE:-} /usr/bin/bash -c '/usr/bin/dnf upgrade --refresh'"                         && cleanup
check pacman  && show "${ELEVATE:-} /usr/bin/bash -c '/usr/bin/pacman -Syyu --needed'"                         && cleanup
check pamac   && show "${ELEVATE:-} /usr/bin/bash -c '/usr/bin/pamac upgrade --refresh'"                       && cleanup

# cleanup
cleanup

# /usr/bin/curl -s https://archlinux.org/mirrorlist/all/ | \
#     /usr/bin/awk '/^## Worldwide/{flag=1; next} /^## /{flag=0} flag && /^#Server/{sub(/^#/,""); print}' \
#     | LC_ALL=C /usr/bin/sort \
#     | /usr/bin/sudo /usr/bin/tee /etc/pacman.d/mirrorlist \
#     && /usr/bin/sudo /usr/bin/pacman -Syyu
