#!/usr/bin/env bash

builtin unset -f "$(builtin compgen -A function)"
builtin unalias -a
export LC_ALL='C'
export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
set -euo pipefail

usage() {
    local reset=$'\033[0m'       # reset
    local bold=$'\033[1m'        # bold
    local italic=$'\033[3m'      # italic
    local underline=$'\033[4m'   # underline
    local reverse=$'\033[7m'     # reverse
    local dim=$'\033[2m'         # dim
    local violet=$'\033[35m'     # violet
    local indigo=$'\033[34m'     # indigo
    local blue=$'\033[94m'       # blue
    local green=$'\033[32m'      # green
    local yellow=$'\033[33m'     # yellow
    local orange=$'\033[91m'     # orange
    local red=$'\033[31m'        # red
    local fmt="${reverse}${bold}"
    cat << EOF
${fmt} Usage ${reset}
    $(basename "${0}") <option> [args...]
${fmt} Options ${reset}
    check                runs diagnostics
    clean                removes downloaded cache
    dump                 print installed packages in NAME\tVERSION format
    update               refresh databases
    upgrade              upgrades all installed packages
${fmt} Options ${reset}
    info     <pkg>       shows information about the package
    files    <pkg>       shows all files provided by the package
    commands <pkg>       shows all commands provided by the package
    search   <query>     search in package names and description
${fmt} Options ${reset}
    download <pkg(s)>    downloads selected packages
    install  <pkg(s)>    installs selected packages
    remove   <pkg(s)>    removes selected packages
EOF
}

pkg_detect() {
    if command -v apt-get >/dev/null 2>&1; then
        PKG="apt-get"
    elif command -v dnf >/dev/null 2>&1; then
        PKG="dnf"
    elif command -v pacman >/dev/null 2>&1; then
        PKG="pacman"
    else
        echo "No supported package manager found"
        exit 1
    fi
    readonly PKG
}

pkg_check() {
    echo "distro id: $( ( source /etc/os-release && printf '%s\n' "${ID}" ) )"

    echo "package manager: ${PKG}"

    if command -v sudo >/dev/null 2>&1; then
        echo "sudo installed: yes"
    else
        echo "sudo installed: no"
    fi

    if [[ "$(id -u)" -ne 0 ]]; then
        echo "non root user: yes"
    else
        echo "root user: no"
    fi

    if command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1; then
        echo "download tool : yes"
    else
        echo "download tool: no"
    fi
}

pkg_clean() {
    case "${PKG}" in
        apt-get) sudo apt-get clean ;;
        dnf)     sudo dnf clean all ;;
        pacman)  sudo pacman -Scc ;;
    esac
}

pkg_commands() {
    local pkg="${1:-}"
    [[ -n "${pkg}" ]] || { usage; exit 1; }

    local IFS=":"
    local -a path_dirs=(${PATH})

    pkg_files "${pkg}" | while IFS= read -r file; do
        [[ -f "${file}" && -x "${file}" ]] || continue

        for dir in "${path_dirs[@]}"; do
            [[ "${file}" == "${dir}/"* ]] || continue

            cmd="${file##*/}"
            printf '%s    %s\n' "${cmd}" "${file}"
            break
        done
    done
}

pkg_download() {
    [[ $# -ge 1 ]] || { usage; exit 1; }

    case "${PKG}" in
        apt-get) sudo apt-get download "${@}" ;;
        dnf)     sudo dnf download "${@}" ;;
        pacman)  sudo pacman -Sw --cachedir "${PWD}" "${@}" ;;
    esac
}


pkg_dump() {
    case "${PKG}" in
        # apt-get) dpkg-query -W -f='${Package}\t${Version}\n' | LC_ALL=C sort ;;
        # dnf)     rpm -qa --qf '%{NAME}\t%{VERSION}\n' | LC_ALL=C sort ;;
        # pacman)  pacman -Qen | awk '{ print $1 "\t" $2 }' | LC_ALL=C sort ;;
        # /usr/bin/dpkg-query --show --showformat '${Package}\t${Version}\n' | LC_ALL=C /usr/bin/sort | /usr/bin/tee /home/dpkg-package-version-all.txt
        # /usr/bin/rpm --query --all --queryformat '%{NAME}\t%{VERSION}\n' | LC_ALL=C /usr/bin/sort | /usr/bin/tee /home/rpm-package-version-all.txt
        # /usr/bin/pacman --query --native | /usr/bin/awk '{ print $1 "\t" $2 }' | LC_ALL=C /usr/bin/sort | /usr/bin/tee /home/dpkg-package-version-all.txt
        apt-get) /usr/bin/dpkg-query --show --showformat '${Package}\t${Version}\n' | LC_ALL=C /usr/bin/sort ;;
        dnf)     /usr/bin/rpm --query --all --queryformat '%{NAME}\t%{VERSION}\n' | LC_ALL=C /usr/bin/sort ;;
        pacman)  /usr/bin/pacman --query --native | /usr/bin/awk '{ print $1 "\t" $2 }' | LC_ALL=C /usr/bin/sort ;;
    esac
}   

pkg_info() {
    local pkg="${1:-}"
    [[ -n "${pkg}" ]] || { usage; exit 1; }

    case "${PKG}" in
        apt-get) apt-cache show "${pkg}" ;;
        dnf)     dnf info "${pkg}" ;;
        pacman)  pacman -Si "${pkg}" ;;
    esac
}

pkg_files() {
    local pkg="${1:-}"
    [[ -n "${pkg}" ]] || { usage; exit 1; }

    case "${PKG}" in
        apt-get) dpkg -L "${pkg}" ;;
        dnf)     rpm -ql "${pkg}" ;;
        pacman)  pacman -Ql "${pkg}" ;;
    esac
}

pkg_install() {
    [[ $# -ge 1 ]] || { usage; exit 1; }

    case "${PKG}" in
        apt-get) sudo apt-get install "${@}" ;;
        dnf)     sudo dnf install "${@}" ;;
        pacman)  sudo pacman -S "${@}" ;;
    esac
}

pkg_remove() {
    [[ $# -ge 1 ]] || { usage; exit 1; }

    case "${PKG}" in
        apt-get) sudo apt-get remove -y "${@}" ;;
        dnf)     sudo dnf remove "${@}" ;;
        pacman)  sudo pacman -R "${@}" ;;
    esac
}

pkg_search() {
    [[ $# -eq 1 ]] || { usage; exit 1; }

    case "${PKG}" in
        apt-get) apt-cache search "${1}" ;;
        dnf)     dnf search "${1}" ;;
        pacman)  pacman -Ss "${1}" ;;
    esac
}

pkg_update() {
    case "${PKG}" in
        apt-get) sudo apt-get update ;;
        dnf)     sudo dnf check-update ;;
        pacman)  sudo pacman -Sy ;;
    esac
}

pkg_upgrade() {
    case "${PKG}" in
        apt-get) sudo apt-get upgrade ;;
        dnf)     sudo dnf upgrade ;;
        pacman)  sudo pacman -Syu ;;
    esac
}

pkg_tasks() {
    local cmd="${1:-}"
    [[ -n "${cmd}" ]] || { usage; exit 1; }
    shift

    case "${cmd}" in
        check)    pkg_check ;;
        clean)    pkg_clean ;;
        commands) pkg_commands "${@}" ;;
        download) pkg_download "${@}" ;;
        dump)     pkg_dump ;;
        files)    pkg_files "${@}" ;;
        info)     pkg_info "${@}" ;;
        install)  pkg_install "${@}" ;;
        remove)   pkg_remove "${@}" ;;
        search)   pkg_search "${@}" ;;
        update)   pkg_update ;;
        upgrade)  pkg_upgrade ;;
        *)        usage; exit 1 ;;
    esac
}

main() {
    [[ $# -ge 1 ]] || { usage; exit 1; }

    pkg_detect
    pkg_tasks "${@}"
}

main "${@}"

