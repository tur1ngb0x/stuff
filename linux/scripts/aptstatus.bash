#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export LC_ALL=C

readonly BASELINE_FILE='/home/pkgs-dump-apt.txt'
readonly CACHE_FILE='/tmp/pkgstatus.cache'

readonly RESET=$'\033[0m'

readonly BOLD=$'\033[1m'
readonly UNDERLINE=$'\033[4m'
readonly REVERSE=$'\033[7m'

readonly RED=$'\033[38;2;255;0;0m'
readonly GREEN=$'\033[38;2;0;255;0m'
readonly BLUE=$'\033[38;2;0;0;255m'

readonly YELLOW=$'\033[38;2;255;255;0m'
readonly CYAN=$'\033[38;2;0;255;255m'
readonly MAGENTA=$'\033[38;2;255;0;255m'

[[ -f "${BASELINE_FILE}" ]] || {
    printf 'error: missing file: %s\n' "${BASELINE_FILE}" >&2
    exit 1
}

declare -A baseline_versions
declare -A current_versions

declare -a \
    uninstalled_packages \
    new_packages \
    upgraded_packages \
    unchanged_packages

build_cache() {
    local db_mtime
    local cache_mtime=0

    db_mtime=$(stat -c '%Y' /var/lib/dpkg/status)

    [[ -f "${CACHE_FILE}" ]] &&
        cache_mtime=$(stat -c '%Y' "${CACHE_FILE}")

    (( db_mtime <= cache_mtime )) &&
        return

    apt-cache dumpavail > "${CACHE_FILE}"
}

get_description() {
    local package="$1"

    awk -v package="${package}" '

        /^Package:/ {
            found = ($2 == package)
        }

        found && /^Description:/ {
            sub(/^Description:[[:space:]]*/, "")
            print
            exit
        }

    ' "${CACHE_FILE}"
}

load_data() {
    local package version

    while IFS=$'\t' read -r package version; do
        baseline_versions["$package"]="$version"
    done < "${BASELINE_FILE}"

    while IFS=$'\t' read -r package version; do
        current_versions["$package"]="$version"
    done < <(
        dpkg-query \
            --show \
            --showformat='${Package}\t${Version}\n'
    )
}

categorize_packages() {
    local package

    for package in "${!baseline_versions[@]}"; do

        if [[ ! -v current_versions["$package"] ]]; then
            uninstalled_packages+=("$package")

        elif [[ "${baseline_versions[$package]}" == "${current_versions[$package]}" ]]; then
            unchanged_packages+=("$package")

        else
            upgraded_packages+=("$package")
        fi
    done

    for package in "${!current_versions[@]}"; do
        [[ -v baseline_versions["$package"] ]] ||
            new_packages+=("$package")
    done

    IFS=$'\n'

    uninstalled_packages=($(sort <<< "${uninstalled_packages[*]}"))
    new_packages=($(sort <<< "${new_packages[*]}"))
    upgraded_packages=($(sort <<< "${upgraded_packages[*]}"))
    unchanged_packages=($(sort <<< "${unchanged_packages[*]}"))

    unset IFS
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

    [[ ${#packages[@]} -eq 0 ]] &&
        return

    local -A descriptions

    local package
    local version
    local description

    local pkg_width=${#title}
    local ver_width=7
    local desc_width=11

    for package in "${packages[@]}"; do

        version="${current_versions[$package]:-${baseline_versions[$package]}}"

        description="$(get_description "${package}")"

        descriptions["$package"]="$description"

        (( ${#package} > pkg_width )) &&
            pkg_width=${#package}

        (( ${#version} > ver_width )) &&
            ver_width=${#version}

        (( ${#description} > desc_width )) &&
            desc_width=${#description}
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
            "${current_versions[$package]:-${baseline_versions[$package]}}" \
            "${RESET}" \
            "${YELLOW}" \
            "${desc_width}" \
            "${descriptions[$package]}" \
            "${RESET}"
    done

    printf '\n'
}

print_results() {

    print_summary 'UNINSTALLED' "${uninstalled_packages[@]}"
    print_summary 'NEW'         "${new_packages[@]}"
    # print_summary 'UPGRADED'    "${upgraded_packages[@]}"
    # print_summary 'UNCHANGED'   "${unchanged_packages[@]}"

    [[ "${1:-}" == '--extra' ]] || {
        printf 'Type %s --extra to see more details.\n' "${0##*/}"
        return
    }

    print_details 'UNINSTALLED' "${uninstalled_packages[@]}"
    print_details 'NEW'         "${new_packages[@]}"
    #print_details 'UPGRADED'    "${upgraded_packages[@]}"
    #print_details 'UNCHANGED'   "${unchanged_packages[@]}"
}

main() {
    build_cache
    load_data
    categorize_packages
    print_results "${1:-}"
}

main "$@"
