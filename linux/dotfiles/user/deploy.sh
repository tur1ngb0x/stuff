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

    # terminal
    '.config/alacritty/alacritty.toml'

    # editor
    '.config/micro/settings.json'
    '.config/sublime-text/Packages/User/Preferences.sublime-settings'
)

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

# begin script from here
deploy "${@}"
