#!/usr/bin/env bash

set -Eeuo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly DEFAULT_WORKDIR="${WORKDIR:-/tmp}"

ISO=""
ISO_NAME=""
MOUNT_DIR=""
IMAGE=""
FONT_DIR=""
INDEX=""
DEFAULT_INDEX=""
WIMINFO_OUTPUT=""

usage() {
    cat <<EOF
Usage:
    ${SCRIPT_NAME} <windows.iso>

Requirements:
    sudo
    wimtools

Environment:
    WORKDIR
        Default: ${DEFAULT_WORKDIR}

Work directories:
    <WORKDIR>/<iso-name>-ISO
    <WORKDIR>/<iso-name>-ID<index>-FONTS
EOF
}

log() {
    printf '%s\n' "$*"
}

warn() {
    printf 'Warning: %s\n' "$*" >&2
}

die() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

confirm() {
    local prompt="$1"
    local reply

    read -r -p "${prompt} [Y/n] " reply

    case "${reply}" in
        ""|y|Y|yes|Yes|YES)
            return 0
            ;;
        *)
            log "Aborted."
            return 1
            ;;
    esac
}

cleanup() {
    local rc=$?

    if [[ -n "${MOUNT_DIR}" ]] && mountpoint -q "${MOUNT_DIR}" 2>/dev/null; then
        sudo umount -- "${MOUNT_DIR}" || true
    fi

    exit "${rc}"
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

parse_args() {
    [[ $# -eq 1 ]] || {
        usage
        exit 1
    }

    ISO="$(readlink -f -- "$1")"

    [[ -f "${ISO}" ]] || die "ISO not found: ${ISO}"

    ISO_NAME="$(basename -- "${ISO}")"
    ISO_NAME="${ISO_NAME%.*}"

    MOUNT_DIR="${DEFAULT_WORKDIR}/${ISO_NAME}-ISO"
}

validate_dependencies() {
    require_command sudo
    require_command mount
    require_command umount
    require_command mountpoint
    require_command readlink
    require_command wiminfo
    require_command wimextract
    require_command awk
    require_command find
    require_command sed
    require_command sort
    require_command tr
    require_command paste
    require_command wc
}

prepare_directories() {
    mkdir -p -- "${MOUNT_DIR}"
}

mount_iso() {
    confirm "Mount ISO at '${MOUNT_DIR}'?" || exit 0

    sudo mount \
        -o loop \
        -- \
        "${ISO}" \
        "${MOUNT_DIR}"
}

locate_install_image() {
    if [[ -f "${MOUNT_DIR}/sources/install.wim" ]]; then
        IMAGE="${MOUNT_DIR}/sources/install.wim"
        return
    fi

    if [[ -f "${MOUNT_DIR}/sources/install.esd" ]]; then
        IMAGE="${MOUNT_DIR}/sources/install.esd"
        return
    fi

    die "install.wim or install.esd not found."
}

cache_wiminfo() {
    WIMINFO_OUTPUT="$(wiminfo "${IMAGE}")"
}

list_images() {
    log "ID  Images"

    printf '%s\n' "${WIMINFO_OUTPUT}" |
    awk '
    /^Index:/ {
        idx = $2
    }

    /^Name:/ {
        sub(/^Name:[[:space:]]*/, "")
        printf "%2d  %s\n", idx, $0
    }
    '
}

find_default_index() {
    DEFAULT_INDEX="$(
        printf '%s\n' "${WIMINFO_OUTPUT}" |
        awk '
        /^Index:/ {
            idx = $2
        }

        /^Name:/ {
            sub(/^Name:[[:space:]]*/, "")
            if ($0 == "Windows 11 Pro") {
                print idx
                exit
            }
        }
        '
    )"
}

prompt_image_index() {
    while true; do
        if [[ -n "${DEFAULT_INDEX}" ]]; then
            read -r -p "Select image index [${DEFAULT_INDEX}]: " INDEX
            INDEX="${INDEX:-${DEFAULT_INDEX}}"
        else
            read -r -p "Select image index: " INDEX
        fi

        if [[ ! "${INDEX}" =~ ^[0-9]+$ ]]; then
            warn "Invalid input. Enter a numeric index."
            continue
        fi

        if wiminfo "${IMAGE}" "${INDEX}" >/dev/null 2>&1; then
            return
        fi

        warn "Image index '${INDEX}' does not exist."
    done
}

prepare_font_directory() {
    FONT_DIR="${DEFAULT_WORKDIR}/${ISO_NAME}-ID${INDEX}-FONTS"

    rm -rf -- "${FONT_DIR}"
    mkdir -p -- "${FONT_DIR}"
}

extract_fonts() {
    confirm "Extract Windows/Fonts to '${FONT_DIR}'?" || exit 0

    wimextract \
        "${IMAGE}" \
        "${INDEX}" \
        Windows/Fonts \
        --dest-dir "${FONT_DIR}"
}

font_count() {
    find "${FONT_DIR}/Fonts" -type f | wc -l
}

font_types() {
    find "${FONT_DIR}/Fonts" -type f \
    | sed 's/.*\.//' \
    | tr '[:upper:]' '[:lower:]' \
    | sort -u \
    | paste -sd ' ' -
}

print_summary() {
    printf '  ISO: %s\n' "${ISO}"
    printf 'Index: %s\n' "${INDEX}"
    printf 'Mount: %s\n' "${MOUNT_DIR}"
    printf 'Fonts: %s\n' "${FONT_DIR}/Fonts"
    printf 'Count: %s\n' "$(font_count)"
    printf 'Types: %s\n' "$(font_types)"
}

open_output_directory() {
    if ! command -v xdg-open >/dev/null 2>&1; then
        return
    fi

    xdg-open "${FONT_DIR}/Fonts" >/dev/null 2>&1 &
}

main() {
    trap cleanup EXIT

    parse_args "$@"
    validate_dependencies
    prepare_directories

    mount_iso
    locate_install_image

    cache_wiminfo
    list_images
    find_default_index
    prompt_image_index

    prepare_font_directory
    extract_fonts

    print_summary
    open_output_directory
}

main "$@"
