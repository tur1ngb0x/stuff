[[ "${-}" != *i* ]] && builtin return

# if argument is a file, is readable, has data, then source it
_s_(){
    [[ $# -eq 0 ]] && builtin echo "usage: _s_ <file1> [file2] ... [fileN]" && builtin return
    local f
    for f in "$@"; do
        if [[ -f "${f}" && -r "${f}" && -s "${f}" ]]; then
        builtin echo "+ builtin source ${f}"
        builtin source "${f}"
        fi
    done
}

_s_ \
    "${HOME}/src/stuff/linux/dotfiles/user/.config/bash/options" \
    "${HOME}/src/stuff/linux/dotfiles/user/.config/bash/path" \
    "${HOME}/src/stuff/linux/dotfiles/user/.config/bash/variables" \
    "${HOME}/src/stuff/linux/dotfiles/user/.config/bash/functions" \
    "${HOME}/src/stuff/linux/dotfiles/user/.config/bash/aliases" \
    "${HOME}/src/stuff/linux/dotfiles/user/.config/bash/prompt" \
    /usr/share/bash-completion/bash_completion \
    /etc/profile.d/PackageKit.sh \
    /usr/share/doc/pkgfile/command-not-found.bash

builtin unset -f _s_

bash-compgen-list(){
    local i
    for i in alias arrayvar binding builtin command directory disabled enabled export file function group helptopic hostname job keyword running service setopt shopt signal stopped user variable; do
        builtin echo "# ---- builtin compgen -A ${i} ---- #"
        builtin compgen -A variable | LC_ALL=C /usr/bin/sort
    done
}

bash-env-list(){
    builtin echo "# ---- /usr/bin/env | LC_ALL=C /usr/bin/sort ---- #"
    /usr/bin/env | LC_ALL=C /usr/bin/sort
}

bash-export-list(){
    builtin echo "# ---- builtin export -p | LC_ALL=C /usr/bin/sort ---- #"
    builtin export -p | LC_ALL=C /usr/bin/sort
}
