#!/usr/bin/env bash


LC_ALL=C
set -euo pipefail


function usage () {
    cat << EOF
Usage:
    $(basename "${0}") <option>

Options:
    check
    clean
    dump
    files <package>
    info <package>
    install <package>
    remove <package>
    search <package>
    update
    upgrade
EOF
}

function pkg_detect () {
    if command -v apt-get &>/dev/null; then
        PKG="apt-get"
    elif command -v dnf &>/dev/null; then
        PKG="dnf"
    elif command -v pacman &>/dev/null; then
        PKG="pacman"
    else
        echo "No supported package manager found"
        exit 1
    fi
    readonly PKG
}

function pkg_check () {
    echo "package manager: ${PKG}"

    if command -v sudo &>/dev/null; then
        echo "is sudo installed: yes"
    else
        echo "is sudo installed: no"
    fi

    if [[ "$(id -u)" -eq 0 ]]; then
        echo "is root user: yes"
    else
        echo "is root user: no"
    fi
}

function pkg_clean () {
    [[ "${PKG}" = "apt-get" ]] && sudo apt-get clean
    [[ "${PKG}" = "dnf" ]] && sudo dnf clean all
    [[ "${PKG}" = "pacman" ]] && sudo pacman -Scc
}

function pkg_dump () {
    [[ "${PKG}" = "apt-get" ]] && dpkg-query -W -f='${Package}    ${Version}\n'
    [[ "${PKG}" = "dnf" ]] && dnf list installed | awk 'NR>1 { print $1 "    " $2 }'
    [[ "${PKG}" = "pacman" ]] && pacman -Q | awk '{ print $1 "    " $2 }'
}

function pkg_info () {
    [[ "${PKG}" = "apt-get" ]] && apt-cache show "${2}"
    [[ "${PKG}" = "dnf" ]] && dnf info "${2}"
    [[ "${PKG}" = "pacman" ]] && pacman -Si "${2}"
}

function pkg_files () {
    [[ "${PKG}" = "apt-get" ]] && dpkg -L "${2}"
    [[ "${PKG}" = "dnf" ]] && rpm -ql "${2}"
    [[ "${PKG}" = "pacman" ]] && pacman -Ql "${2}"
}

function pkg_install () {
    [[ "${PKG}" = "apt-get" ]] && sudo apt-get install "${@:2}"
    [[ "${PKG}" = "dnf" ]] && sudo dnf install "${@:2}"
    [[ "${PKG}" = "pacman" ]] && sudo pacman -S "${@:2}"
}

function pkg_remove () {
    [[ "${PKG}" = "apt-get" ]] && sudo apt-get remove -y "${@:2}"
    [[ "${PKG}" = "dnf" ]] && sudo dnf remove "${@:2}"
    [[ "${PKG}" = "pacman" ]] && sudo pacman -R "${@:2}"
}

function pkg_search () {
    [[ "${PKG}" = "apt-get" ]] && apt-cache search "${@:2}"
    [[ "${PKG}" = "dnf" ]] && dnf search "${@:2}"
    [[ "${PKG}" = "pacman" ]] && pacman -Ss "${@:2}"
}

function pkg_update () {
    [[ "${PKG}" = "apt-get" ]] && sudo apt-get update
    [[ "${PKG}" = "dnf" ]] && sudo dnf check-update
    [[ "${PKG}" = "pacman" ]] && sudo pacman -Sy
}

function pkg_upgrade () {
    [[ "${PKG}" = "apt-get" ]] && sudo apt-get upgrade
    [[ "${PKG}" = "dnf" ]] && sudo dnf upgrade
    [[ "${PKG}" = "pacman" ]] && sudo pacman -Syu
}

function pkg_tasks () {
    case "${1}" in
        check)   pkg_check   "${@}" ;;
        clean)   pkg_clean   "${@}" ;;
        dump)    pkg_dump    "${@}" ;;
        files)   pkg_files   "${@}" ;;
        info)    pkg_info    "${@}" ;;
        install) pkg_install "${@}" ;;
        remove)  pkg_remove  "${@}" ;;
        search)  pkg_search  "${@}" ;;
        update)  pkg_update  "${@}" ;;
        upgrade) pkg_upgrade "${@}" ;;
        *)       usage; exit 1 ;;
    esac
}

function main () {
    if [[ $# -eq 0 ]]; then
        usage
        exit 1
    fi

    pkg_detect
    pkg_tasks "${@}"
}

# begin script from here
main "${@}"
