#!/usr/bin/env --ignore-environment --split-string bash --noprofile --norc

builtin set -euo pipefail
LC_ALL='C'; builtin export LC_ALL
PATH='/usr/local/sbin:/usr/local/bin:/usr/bin'; builtin export PATH

[[ "${BASH_SOURCE[0]}" != "${0}" ]] && { builtin printf -- '\033[1;31m%s\033[0m\n' 'ERROR: Do not source this script' >&2;             builtin return 1; }
[[ "${EUID}" -eq 0 ]]               && { builtin printf -- '\033[1;31m%s\033[0m\n' 'ERROR: Do not run this script as a root user' >&2; builtin exit 1; }
[[ "${#}" -ne 0 ]]                  && { builtin printf -- '\033[1;31m%s\033[0m\n' 'ERROR: Do not run this script with arguments' >&2; builtin exit 1; }

# code-family=(
#     # vscode native
#     "${HOME}/.config/Code/User/settings.json"
#     # vscodium native
#     "${HOME}/.config/VSCodium/User/settings.json"
#     # code-oss native
#     "${HOME}/.config/Code - OSS/User/settings.json"

#     # vscode flatpak
#     "${HOME}/.var/app/com.visualstudio.code/config/Code/User/settings.json"
#     # vscodium flatpak
#     "${HOME}/.var/app/com.vscodium.codium/config/VSCodium/User/settings.json"

#     # vscode snap
#     "${HOME}/snap/code/current/.config/Code/User/settings.json"
#     # vscodium snap
#     "${HOME}/snap/codium/current/.config/VSCodium/User/settings.json"
# )

cwd="$(builtin cd -- "$(/usr/bin/dirname -- "${BASH_SOURCE[0]}")" && builtin pwd -P --)"

deploy(){
    dot_file="${cwd:?}/${1:?}"
    target_file="${2:?}"
    /usr/bin/install -d  -- "$(/usr/bin/dirname ${target_file:?})"
    /usr/bin/ln -s -r -f -- "${dot_file:?}" "${target_file:?}"
    echo "${target_file}|$(/usr/bin/readlink -f ${target_file:?})"
}

main(){
    # profile
    deploy '.profile' "${HOME}/.profile"

    # bashrc
    deploy '.bashrc' "${HOME}/.bashrc"

    # alacritty
    deploy '.config/alacritty/alacritty.toml' "${HOME}/.config/alacritty/alacritty.toml"

    # git
    deploy '.config/git/config' "${HOME}/.config/git/config"

    # micro
    deploy '.config/micro/settings.json' "${HOME}/.config/micro/settings.json"

    # code
    deploy '.config/Code/User/settings.json' "${HOME}/.config/Code/User/settings.json"
    deploy '.config/Code/User/settings.json' "${HOME}/.var/app/com.visualstudio.code/config/Code/User/settings.json"

    # zed
    deploy '.config/zed/settings.json' "${HOME}/.var/app/dev.zed.Zed/config/zed/settings.json"
    deploy '.config/zed/settings.json' "${HOME}/.config/zed/settings.json"
}

main "${@}" | /usr/bin/column -s '|' -N DOTFILE,ORIGIN -t
