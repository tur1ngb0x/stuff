[[ "${-}" != *i* ]] && builtin return

_s_() {
    [[ $# -eq 0 ]] && builtin printf "usage: %s <file1> [file2] ... [fileN]\n" "${FUNCNAME[0]}" && builtin return
    local f
    for f in "$@"; do [[ -f "${f}" && -r "${f}" && -s "${f}" ]] && builtin source "${f}"; done
}

_s_ \
    /usr/share/bash-completion/bash_completion \
    /etc/profile.d/PackageKit.sh \
    /usr/share/doc/pkgfile/command-not-found.bash

_s_ \
    "${HOME}/src/stuff/linux/dotfiles/user/.config/bash/options.bash" \
    "${HOME}/src/stuff/linux/dotfiles/user/.config/bash/path.bash" \
    "${HOME}/src/stuff/linux/dotfiles/user/.config/bash/variables.bash" \
    "${HOME}/src/stuff/linux/dotfiles/user/.config/bash/functions.bash" \
    "${HOME}/src/stuff/linux/dotfiles/user/.config/bash/aliases.bash" \
    "${HOME}/src/stuff/linux/dotfiles/user/.config/bash/prompt.bash"

builtin unset -f _s_
