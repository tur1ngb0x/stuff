#!/usr/bin/env bash

builtin set -euo pipefail

TARGET_DIR="${HOME}/Downloads"

declare -A DIR_EXTS=(
    ["Archives"]="7z gz img iso rar tar xz zip"
    ["Documents"]="doc docx pdf txt xlsx"
    ["Music"]="flac mp3 ogg wav"
    ["Pictures"]="gif jpeg jpg png webp"
    ["Projects"]="conf go json ps1 py sh sql toml yaml"
    ["Videos"]="avi mkv mov mp4 webm"
)

for folder in "${!DIR_EXTS[@]}"; do
    /usr/bin/mkdir -p "${HOME}/${folder}"
done

declare -A EXT_DIRS

for folder in "${!DIR_EXTS[@]}"; do
    for ext in ${DIR_EXTS[$folder]}; do
        EXT_DIRS["${ext}"]="${HOME}/${folder}"
    done
done

moves=()

for file in "${TARGET_DIR}"/*; do
    [[ -f "${file}" ]] || continue

    name="${file##*/}"
    ext="${name##*.}"
    ext="${ext,,}"

    dest_dir="${EXT_DIRS[${ext}]:-}"
    [[ -n "${dest_dir}" ]] || continue

    dest="${dest_dir}/${name}"
    [[ -e "${dest}" ]] && continue

    moves+=("${file}|${name}|${dest_dir##*/}|${dest}")
done

if [[ "${#moves[@]}" -eq 0 ]]; then
    builtin echo "No files to move."
    builtin exit 0
fi

builtin echo "Planned moves:"

for item in "${moves[@]}"; do
    rest="${item#*|}"

    name="${rest%%|*}"
    rest="${rest#*|}"

    folder="${rest%%|*}"

    builtin echo "${folder}|<-|\"${name}\""
done | LC_ALL=C /usr/bin/sort | /usr/bin/column -s '|' -t

builtin printf "Proceed? (N/y): "
builtin read -r answer

case "${answer}" in
    y|Y)
        for item in "${moves[@]}"; do
            src="${item%%|*}"
            dest="${item##*|}"

            /usr/bin/mv "${src}" "${dest}"
        done

        builtin echo "Done."
        ;;
    *)
        builtin echo "Cancelled."
        ;;
esac
