#!/usr/bin/env bash

add_newline(){
    builtin printf "%s\n" "" 2>/dev/null
}

get_distro(){
    builtin printf "DISTRO|%s\n" \
        "$(/usr/bin/sed --silent 's/^PRETTY_NAME="\([^"]*\)"/\1/p' /etc/os-release 2>/dev/null)"
}

get_kernel(){
    builtin printf "KERNEL|%s%s\n" \
        "$(/usr/bin/uname -r)" \
        "$([[ -f /var/run/reboot-required ]] && builtin echo " (!)" 2>/dev/null)"
}

get_uptime(){
    builtin printf "UPTIME|%s\n" \
        "$(/usr/bin/awk '{ \
            total=$1; \
            d=int(total/86400); r=total%86400; \
            h=int(r/3600); r%=3600; \
            m=int(r/60); s=int(r%60); \
            pct=(total/86400)*100; \
            if (d > 0) printf "%d:", d; \
            if (d > 0 || h > 0) printf "%d:", h; \
            if (d > 0 || h > 0 || m > 0) printf "%d:", m; \
            printf "%d", s; \
            printf " (%.0f%%)\n", pct \
        }' /proc/uptime)" 2>/dev/null
}

get_shell(){
    local SHELL_NAME="${SHELL##*/}"
    local SHELL_VERSION=""

    case "${SHELL_NAME}" in
        "bash")
            SHELL_VERSION=" $(builtin echo "${BASH_VERSION}" | /usr/bin/cut -d'(' -f1)"
            ;;
        "fish")
            SHELL_VERSION=" $(/usr/bin/fish --version | /usr/bin/awk "{print \$3}")"
            ;;
        "zsh")
            SHELL_VERSION=" $(/usr/bin/zsh --version | /usr/bin/awk "{print \$2}")"
            ;;
    esac

    builtin printf "SHELL|%s%s\n" \
        "${SHELL_NAME}" \
        "${SHELL_VERSION}"
}

get_disk(){
    builtin printf "DISK|%s\n" \
        "$(/usr/bin/df / 2>/dev/null | /usr/bin/awk 'FNR==2 {printf "%.2fG (%.0f%%)\n", $3/1024/1024, $3/$2*100}')"
}

get_memory(){
    builtin printf "MEMORY|%s\n" \
        "$(/usr/bin/free | /usr/bin/awk 'FNR==2 {printf "%.2fG (%.0f%%)\n", $3/1024/1024, $3/$2*100}')" 2>/dev/null
}

get_session(){
    builtin printf "SESSION|%s (%s)\n" \
        "${XDG_SESSION_DESKTOP:-Unknown}" \
        "${XDG_SESSION_TYPE:-Unknown}"
}

print_gradient(){
    local funcs=("$@")
    local n=${#funcs[@]}
    local i=0

    for f in "${funcs[@]}"; do
        local r=$((148 - (148-25)*i/(n-1)))
        local g=$((0 + (212-0)*i/(n-1)))
        local b=$((211 + (255-211)*i/(n-1)))

        builtin printf "\033[38;2;%d;%d;%dm" "$r" "$g" "$b"
        "$f"
        builtin printf "\033[0m"

        i=$((i+1))
    done
}

enclose_box(){
    /usr/bin/awk '
    {
        lines[NR] = $0
        if (length($0) > max) max = length($0)
    }
    END {
        printf "+"
        for (i=0; i<max+2; i++) printf "-"
        printf "+\n"

        for (i=1; i<=NR; i++) {
            printf "| %-*s |\n", max, lines[i]
        }

        printf "+"
        for (i=0; i<max+2; i++) printf "-"
        printf "+\n"
    }'
}

main(){
    get_distro
    get_kernel
    get_shell
    get_session
    get_uptime
    get_disk
    get_memory
}

main "${@}" | /usr/bin/column -s '|' -o ' => ' -R 1 -t
