function path_prefix () {
    local dir
    for dir in "$@"; do [[ -d "${dir}" ]] || continue; PATH="${dir}:${PATH}"; done
}

function path_suffix () {
    local dir
    for dir in "$@"; do [[ -d "${dir}" ]] || continue; PATH="${PATH}:${dir}"; done
}

function path_clean () {
    local newpath
    newpath="$(builtin printf '%s' "$PATH" | /usr/bin/awk -v RS=: '!seen[$0]++ && !system("test -d \"" $0 "\""){if(n++)printf ":";printf $0}')"
    [[ -n $newpath ]] && PATH=$newpath
}

PATH='/usr/games:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

path_prefix "/var/lib/flatpak/exports/bin"                 # system flatpaks
path_prefix "${HOME}/src/npm/bin"                          # user npm
path_prefix "${HOME}/.local/share/flatpak/exports/bin"     # user flatpaks
path_prefix "${HOME}/.local/bin"                           # user binaries
path_prefix "${HOME}/src/stuff/linux/scripts"              # user scripts

path_clean

builtin export PATH
