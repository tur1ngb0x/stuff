#!/system/bin/sh

# Aliases
builtin alias c='/system/bin/clear'
builtin alias ls='/system/bin/ls --color=auto -A -a -F -p -g -h -l -o'
builtin alias grep='/system/bin/grep --color=auto'
builtin alias diff='/system/bin/diff --color=auto'
builtin alias ip='/system/bin/ip --color'
builtin alias chgrp='/system/bin/chgrp -v'
builtin alias chmod='/system/bin/chmod -v'
builtin alias chown='/system/bin/chown -v'
builtin alias cp='/system/bin/cp -v'
builtin alias ln='/system/bin/ln -v'
builtin alias mkdir='/system/bin/mkdir -v -p'
builtin alias mv='/system/bin/mv -v'
builtin alias rm='/system/bin/rm -v -f'
builtin alias rmdir='/system/bin/rmdir'

du-summary() {
    dir="${1:-${PWD}}"

    du -k -d 1 "${dir}" | sort -n -r | \
    awk '
    BEGIN {
        red    = "\033[31m"
        yellow = "\033[33m"
        cyan   = "\033[36m"
        green  = "\033[32m"
        reset  = "\033[0m"
    }

    function human(x, unit, i) {
        split("K M G T P", unit, " ")

        i = 1

        while (x >= 1024 && i < 5) {
            x /= 1024
            i++
        }

        return sprintf("%.2f %s", x, unit[i])
    }

    {
        size = human($1)

        split(size, parts, " ")

        num  = parts[1]
        unit = parts[2]

        path = $0
        sub(/^[0-9]+[[:space:]]+/, "", path)

        color = ""

        if (unit == "T") {
            color = red
        } else if (unit == "G") {
            color = yellow
        } else if (unit == "M") {
            color = cyan
        } else if (unit == "K") {
            color = green
        }

        printf "%s%7s %s%s    %s\n", color, num, unit, reset, path
    }'

    unset dir
}

lstree() {
    dir=${1:-.}
    depth=${2:-1}
    type=${3:-all}

    find_type=''

    if [ "${type}" = 'folder' ]; then
        find_type='-type d'
    elif [ "${type}" = 'file' ]; then
        find_type='-type f'
    fi

    /system/bin/find "${dir}" -maxdepth "${depth}" ${find_type} \
        | /system/bin/sort \
        | /system/bin/awk -F/ '
    {
        for (i = 2; i < NF; i++) {
            printf "    "
        }

        if ($NF != "") {
            print $NF
        }
    }'
}
wa-cleanup() {
    base="/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media"

    [ -d "${base}" ] || {
        echo "WHATSAPP MEDIA DIRECTORY NOT FOUND"
        return 1
    }

    echo "LISTING UNUSED WHATSAPP MEDIA DIRECTORIES..."
    echo ""
    find "${base}" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        ! -name "WhatsApp Documents" \
        ! -name "WhatsApp Images" \
        ! -name "WhatsApp Video" \
        -printf '"%p"\n'
        #-exec rm -rf "{}" +

    unset base
}

builtin cd "$(/system/bin/realpath /sdcard)" && ls

PS1='$(/system/bin/printf "\033[1;92m%s@%s \033[1;36m%s\033[0m" "${USER:-username?}" "${HOSTNAME:-hostname?}" "${PWD}")
\$ '; builtin export PS1

# HOME="$(/system/bin/realpath /sdcard)"; builtin export HOME
