#!/system/bin/sh

BASE="$(realpath "/sdcard")"
TARGET="${BASE}/Download"

APPS="${BASE}/Applications"
ARCHIVES="${BASE}/Archives"
DOCUMENTS="${BASE}/Documents"
MOVIES="${BASE}/Movies"
MUSIC="${BASE}/Music"
PICTURES="${BASE}/Pictures"
SOURCE="${BASE}/Source"

APK_EXTS="apk apks xapk exe"
ARCHIVE_EXTS="7z gz img iso rar tar xz zip"
DOCUMENT_EXTS="doc docx pdf txt xlsx"
MUSIC_EXTS="flac mp3 ogg wav wma"
PICTURE_EXTS="gif heic jpeg jpg png webp"
SOURCE_EXTS="conf go json ps1 py sh sql toml yaml yml"
VIDEO_EXTS="avi mkv mov mp4 webm 3gp"

create_dirs() {
    echo "CREATING REQUIRED DIRECTORIES..."

    mkdir -p \
        "${APPS}" \
        "${ARCHIVES}" \
        "${DOCUMENTS}" \
        "${MOVIES}" \
        "${MUSIC}" \
        "${PICTURES}" \
        "${SOURCE}"
}

has_ext() {
    ext="${1}"
    shift

    for x in "${@}"; do
        [ "${x}" = "${ext}" ] && return 0
    done

    return 1
}

get_dest_dir() {
    ext="${1}"

    if has_ext "${ext}" ${APK_EXTS}; then
        printf "%s\n" "${APPS}"

    elif has_ext "${ext}" ${ARCHIVE_EXTS}; then
        printf "%s\n" "${ARCHIVES}"

    elif has_ext "${ext}" ${DOCUMENT_EXTS}; then
        printf "%s\n" "${DOCUMENTS}"

    elif has_ext "${ext}" ${MUSIC_EXTS}; then
        printf "%s\n" "${MUSIC}"

    elif has_ext "${ext}" ${PICTURE_EXTS}; then
        printf "%s\n" "${PICTURES}"

    elif has_ext "${ext}" ${SOURCE_EXTS}; then
        printf "%s\n" "${SOURCE}"

    elif has_ext "${ext}" ${VIDEO_EXTS}; then
        printf "%s\n" "${MOVIES}"

    else
        return 1
    fi
}

move_file() {
    src="${1}"
    dst_dir="${2}"

    [ -f "${src}" ] || return 0

    name="$(basename "${src}")"
    dst="${dst_dir}/${name}"

    if [ -e "${dst}" ]; then
        i=1

        while [ -e "${dst_dir}/${i}_${name}" ]; do
            i=$((i + 1))
        done

        dst="${dst_dir}/${i}_${name}"
    fi

    printf "%s -> %s\n" "${name}" "$(basename "${dst_dir}")"

    mv "${src}" "${dst}"
}

main() {
    echo "STARTING FILE ORGANIZATION..."

    create_dirs

    echo "SCANNING DOWNLOAD DIRECTORY..."

    find "${TARGET}" -maxdepth 1 -type f | while IFS= read -r file; do
        name="$(basename "${file}")"

        case "${name}" in
            *.*)
                ext="${name##*.}"
                ;;
            *)
                continue
                ;;
        esac

        ext="$(printf "%s" "${ext}" | tr "[:upper:]" "[:lower:]")"

        if dest_dir="$(get_dest_dir "${ext}")"; then
            move_file "${file}" "${dest_dir}"
        fi
    done

    echo "SEARCHING FOR EMPTY DIRECTORIES..."
    find "${BASE}" -path "${BASE}/Android" -prune -o -type d -empty -printf "'%p'\n" | sort

    echo "SEARCHING FOR .THUMBNAILS DIRECTORIES..."
    find "${BASE}" -type d -name ".thumbnails" -printf "'%p'\n" | sort

    # echo "SEARCHING FOR .DOT FILES..."
    # find "${BASE}" -name ".*" ! -name "." ! -name ".." -printf "'%p'\n" | sort

    # echo "SEARCHING FOR TOP 25 LARGEST FILES..."
    # find "${BASE}" -path "${BASE}/Android" -prune -o -type f -exec du -k "{}" \; | sort -n -r | head -n 25 | \
    # awk '
    # function human(x, unit, i) {
    #     split("K M G T P", unit, " ")

    #     i = 1

    #     while (x >= 1024 && i < 5) {
    #         x /= 1024
    #         i++
    #     }

    #     return sprintf("%.2f %s", x, unit[i])
    # }

    # {
    #     size = human($1)

    #     path = $0
    #     sub(/^[0-9]+[[:space:]]+/, "", path)

    #     printf "%8s %s\n", size, path
    # }'

}

main "${@}"
