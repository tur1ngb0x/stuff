#!/usr/bin/env bash

set -euo pipefail

[[ "${BASH_SOURCE[0]}" != "${0}" ]] && builtin printf '%s\n' 'Exiting: Do not source this script' && builtin exit 1
#[[ "${EUID}" -eq 0 ]]               && builtin printf '%s\n' 'Do not run as root' && builtin exit 1
[[ ! -t 1 ]]                        && builtin printf '%s\n' 'Exiting: No interactive terminal detected' && builtin exit 1

while IFS= read -r fn; do builtin unset -f "${fn}"; done < <(builtin compgen -A function)
builtin unalias -a
export LC_ALL='C'
export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
TIMESTAMP="/usr/bin/date '+%Y-%m-%d %a %H:%M:%S'"

function timestamp () {
    /usr/bin/date '+%Y-%m-%d %a %H:%M:%S'
}

function cache () {
    local cached_timestamp

    if [[ -r '/tmp/upgrade.cache' ]]; then
        IFS= builtin read -r cached_timestamp < '/tmp/upgrade.cache'
        builtin printf '%s\n' "Exiting: System was already updated during this boot session at ${cached_timestamp}"
        builtin exit 1
    fi

    timestamp > '/tmp/upgrade.cache'
}

function show () {
    builtin printf -- '\033[7m # %s | %s \033[0m\n' "$(timestamp)" "${*}"
    builtin eval "${@:?}"
}

function check () {
    [[ -x "/usr/bin/${1:?}" ]]
}

function elevate () {
    if [[ ${EUID} -ne 0 ]]; then
        if check 'sudo'; then
            ELEVATE='/usr/bin/sudo'
        fi
    fi

    #show "${ELEVATE:-} -v"
}

function upgrade () {
    if check 'am'; then      show "/usr/bin/bash -c 'am sync && am update'"; fi
    if check 'code'; then    show "/usr/bin/bash -c 'code --update-extensions'"; fi
    if check 'pipx'; then    show "/usr/bin/bash -c 'pipx upgrade-all'"; fi
    if check 'flatpak'; then show "/usr/bin/bash -c 'flatpak update'"; fi
    if check 'snap'; then    show "${ELEVATE:-} /usr/bin/bash -c 'snap refresh'"; fi

    if check 'apt-get'; then show "${ELEVATE:-} /usr/bin/bash -c '/usr/bin/apt-get update && /usr/bin/apt-get dist-upgrade'"; fi
    if check 'dnf'; then     show "${ELEVATE:-} /usr/bin/bash -c '/usr/bin/dnf upgrade --refresh'"; fi
    if check 'pacman'; then  show "${ELEVATE:-} /usr/bin/bash -c '/usr/bin/pacman -Syyu --needed'"; fi
    if check 'pamac'; then   show "${ELEVATE:-} /usr/bin/bash -c '/usr/bin/pamac upgrade --refresh'"; fi
}

function main () {
    cache
    elevate
    upgrade
}

main

# /usr/bin/curl -s https://archlinux.org/mirrorlist/all/ | \
#     /usr/bin/awk '/^## Worldwide/{flag=1; next} /^## /{flag=0} flag && /^#Server/{sub(/^#/,""); print}' \
#     | LC_ALL=C /usr/bin/sort \
#     | /usr/bin/sudo /usr/bin/tee /etc/pacman.d/mirrorlist \
#     && /usr/bin/sudo /usr/bin/pacman -Syyu
