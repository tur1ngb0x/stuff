#!/usr/bin/env bash

export LC_ALL=C

readonly BASELINE_FILE='/home/pkgs-pacman.txt'
readonly CACHE_FILE='/tmp/pakmanstatus.cache'

readonly RESET=$'\033[0m'

# Text attributes
readonly BOLD=$'\033[1m'
readonly UNDERLINE=$'\033[4m'
readonly REVERSE=$'\033[7m'

# Primary colors
readonly RED=$'\033[38;2;255;0;0m'
readonly GREEN=$'\033[38;2;0;255;0m'
readonly BLUE=$'\033[38;2;0;0;255m'

# Secondary colors
readonly YELLOW=$'\033[38;2;255;255;0m'
readonly CYAN=$'\033[38;2;0;255;255m'
readonly MAGENTA=$'\033[38;2;255;0;255m'

# Tertiary colors
readonly ORANGE=$'\033[38;2;255;128;0m'
readonly CHARTREUSE=$'\033[38;2;128;255;0m'
readonly SPRING_GREEN=$'\033[38;2;0;255;128m'
readonly AZURE=$'\033[38;2;0;128;255m'
readonly VIOLET=$'\033[38;2;128;0;255m'
readonly ROSE=$'\033[38;2;255;0;128m'

[[ -f "${BASELINE_FILE}" ]] || {
    printf 'error: missing file: %s\n' "${BASELINE_FILE}" >&2
    exit 1
}

declare -a \
    baseline \
    current \
    foreign_packages \
    uninstalled_packages \
    new_packages \
    upgraded_packages \
    unchanged_packages

declare -A versions

get_description() {
    local package="$1"

    awk -F ': ' -v package="${package}" '
        /^Name/ {
            found = ($2 == package)
        }

        found && /^Description/ {
            print $2
            exit
        }
    ' "${CACHE_FILE}"
}

print_summary() {
    local title="$1"
    shift

    printf '\033[7m# %s (%d)\033[0m\n' \
        "${title}" \
        "$#"

    printf '%s\n\n' "${*:-NA}"
}

print_details() {
    local title="$1"
    shift

    local packages=("$@")

    [[ ${#packages[@]} -eq 0 ]] && return

    local -A descriptions=()

    local package version description
    local pkg_width=${#title}
    local ver_width=${#VERSION}
    local desc_width=${#DESCRIPTION}

    for package in "${packages[@]}"; do
        version="${versions[$package]}"
        description="$(get_description "${package}")"

        descriptions["$package"]="$description"

        (( ${#package} > pkg_width )) && pkg_width=${#package}
        (( ${#version} > ver_width )) && ver_width=${#version}
        (( ${#description} > desc_width )) && desc_width=${#description}
    done

    printf '%b%-*s%b  %b%-*s%b  %b%-*s%b\n' \
        "${REVERSE}${GREEN}"  "${pkg_width}"  "${title}"       "${RESET}" \
        "${REVERSE}${CYAN}"   "${ver_width}"  VERSION          "${RESET}" \
        "${REVERSE}${YELLOW}" "${desc_width}" DESCRIPTION      "${RESET}"

    for package in "${packages[@]}"; do
        printf '%b%-*s%b  %b%-*s%b  %b%-*s%b\n' \
            "${GREEN}" \
            "${pkg_width}" \
            "${package}" \
            "${RESET}" \
            "${CYAN}" \
            "${ver_width}" \
            "${versions[$package]}" \
            "${RESET}" \
            "${YELLOW}" \
            "${desc_width}" \
            "${descriptions[$package]}" \
            "${RESET}"
    done

    printf '\n'
}

build_cache() {
    local db_mtime=0
    local cache_mtime=0

    db_mtime=$(
        find /var/lib/pacman/local \
            -type f \
            -printf '%T@\n' |
        sort -nr |
        head -n1
    )

    [[ -f "${CACHE_FILE}" ]] &&
        cache_mtime=$(stat -c '%Y' "${CACHE_FILE}")

    (( ${db_mtime%.*} <= cache_mtime )) && return

    {
        /usr/bin/pacman --query --info

        /usr/bin/pacman \
            --sync \
            --list |
        awk '{ print $2 }' |
        xargs -r /usr/bin/pacman --sync --info
    } > "${CACHE_FILE}"
}

load_data() {
    mapfile -t baseline < <(
        awk '{ print $1, $2 }' "${BASELINE_FILE}" | sort
    )

    mapfile -t current < <(
        /usr/bin/pacman --query --explicit --native | sort
    )

    mapfile -t foreign_packages < <(
        /usr/bin/pacman --query --quiet --foreign | sort
    )

    local line package version

    for line in "${baseline[@]}"; do
        read -r package version <<< "${line}"
        versions["$package"]="$version"
    done

    for line in "${current[@]}"; do
        read -r package version <<< "${line}"
        versions["$package"]="$version"
    done

    while read -r package version; do
        versions["$package"]="$version"
    done < <(
        /usr/bin/pacman --query --foreign
    )
}

categorize_packages() {
    declare -A current_versions
    declare -A baseline_packages

    local line package version

    for line in "${current[@]}"; do
        read -r package version <<< "${line}"
        current_versions["$package"]="$version"
    done

    for line in "${baseline[@]}"; do
        read -r package version <<< "${line}"

        baseline_packages["$package"]=1

        if [[ ! -v current_versions["$package"] ]]; then
            uninstalled_packages+=("$package")
        elif [[ "${current_versions[$package]}" == "$version" ]]; then
            unchanged_packages+=("$package")
        else
            upgraded_packages+=("$package")
        fi
    done

    for line in "${current[@]}"; do
        read -r package version <<< "${line}"

        [[ -v baseline_packages["$package"] ]] ||
            new_packages+=("$package")
    done
}

print_results() {
    print_summary 'FOREIGN'     "${foreign_packages[@]}"
    print_summary 'UNINSTALLED' "${uninstalled_packages[@]}"
    print_summary 'NEW'         "${new_packages[@]}"
    print_summary 'UPGRADED'    "${upgraded_packages[@]}"
    print_summary 'UNCHANGED'   "${unchanged_packages[@]}"

    [[ "$1" == '--extra' ]] || {
        printf 'Type %s --extra to see more details.\n' "${0##*/}"
        return
    }

    print_details 'FOREIGN'     "${foreign_packages[@]}"
    print_details 'UNINSTALLED' "${uninstalled_packages[@]}"
    print_details 'NEW'         "${new_packages[@]}"
    print_details 'UPGRADED'    "${upgraded_packages[@]}"
    print_details 'UNCHANGED'   "${unchanged_packages[@]}"
}

main() {
    load_data
    categorize_packages
    build_cache
    print_results "$1"
}

main "$@"
