#!/usr/bin/env --ignore-environment --split-string bash --noprofile --norc

builtin set -euo pipefail
LC_ALL=C; builtin export LC_ALL
PATH=/usr/local/sbin:/usr/local/bin:/usr/bin; builtin export PATH

[[ "${BASH_SOURCE[0]}" != "${0}" ]] && { builtin printf -- '\033[1;31m%s\033[0m\n' 'ERROR: Do not source this script' >&2;             builtin return 1; }
[[ "${EUID}" -eq 0 ]]               && { builtin printf -- '\033[1;31m%s\033[0m\n' 'ERROR: Do not run this script as a root user' >&2; builtin exit 1; }
[[ "${#}" -ne 0 ]]                  && { builtin printf -- '\033[1;31m%s\033[0m\n' 'ERROR: Do not run this script with arguments' >&2; builtin exit 1; }

dotfiles=(
    # shell
    '.profile'
    '.bashrc'

    # git
    '.config/git/config'

    # alacritty
    '.config/alacritty/alacritty.toml'

    # vscode
    '.config/Code/User/settings.json'

    # editor
    '.config/micro/settings.json'
)

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
    printf '\033[1;31m%s\033[0m\n' 'DEPLOYING:'
    for i in "${dotfiles[@]}"; do
        /usr/bin/install -d -m 0755 --    "${HOME}/$(/usr/bin/dirname "${i}")"
        #/usr/bin/install -v -m 0644 --   "${cwd}/${i}" "${HOME}/${i}"
        /usr/bin/ln -s -f --              "${cwd}/${i}" "${HOME}/${i}"
        /usr/bin/ls -al --color=always -- "${HOME}/${i}"
    done
}

fixes(){
    if [[ -f "${HOME}/.bash_profile" ]]; then
        /usr/bin/rm -f -- "${HOME}/.bash_profile"
    fi
}

# begin script from here
deploy "${@}"
fixes
