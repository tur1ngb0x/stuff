[[ "${-}" != *i* ]] && builtin return

_ies() {
    local f
    for f in "$@"; do
        [[ ! "${f}" =~ ^[0-9]+$ ]] || continue
        [[ -f "${f}" ]] || continue
        builtin source "${f}"
    done
}

_ies \
    "${HOME}/src/stuff/linux/dotfiles/user/.config/bash/options" \
    "${HOME}/src/stuff/linux/dotfiles/user/.config/bash/path" \
    "${HOME}/src/stuff/linux/dotfiles/user/.config/bash/variables" \
    "${HOME}/src/stuff/linux/dotfiles/user/.config/bash/functions" \
    "${HOME}/src/stuff/linux/dotfiles/user/.config/bash/aliases" \
    "${HOME}/src/stuff/linux/dotfiles/user/.config/bash/prompt" \
    /usr/share/bash-completion/bash_completion \
    /etc/profile.d/PackageKit.sh \
    /usr/share/doc/pkgfile/command-not-found.bash

unset -f _ies
