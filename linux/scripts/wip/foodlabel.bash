#!/usr/bin/env bash

set -euo pipefail

readonly FONT_SANS="/usr/share/fonts/Adwaita/AdwaitaSans-Regular.ttf"
readonly FONT_MONO="/usr/share/fonts/TTF/IosevkaTermNerdFont-Light.ttf"
readonly UNDERCOLOR="#000000BF"

usage() {
    cat <<EOF
Usage:
    $(basename "$0") input_image protein_gm fat_gm carb_gm "My Meal Name"
EOF
}

die() {
    printf 'error: %s\n' "${*}" >&2
    exit 1
}

parse_arguments() {
    [[ $# -eq 5 ]] || {
        usage
        exit 1
    }

    input="${1}"
    protein="${2}"
    fat="${3}"
    carbs="${4}"
    meal="${5}"
}

validate() {
    [[ -f "${input}" ]] || die "${input} not found"
    command -v magick >/dev/null 2>&1 || die "ImageMagick is not installed"
    [[ -f "${FONT_SANS}" ]] || die "Font not found: ${FONT_SANS}"
    [[ -f "${FONT_MONO}" ]] || die "Font not found: ${FONT_MONO}"
}

prepare() {
    padding=$'\u00A0'
    separator=' '

    output="$(sed -E 's/.*/\L&/; s/[^a-z0-9]+/_/g; s/^_+|_+$//g' <<< "${meal}").jpg"

    dim="$(magick "${input}" -format '%[fx:min(w,h)]' info:)"

    meal_ps="$((dim / 15))"
    nutrition_ps="$((dim / 30))"

    meal_y="$((meal_ps + dim / 100))"
    nutrition_y="$((dim / 50))"

    kcal="$(awk -v p="${protein}" -v f="${fat}" -v c="${carbs}" 'BEGIN { printf "%.1f", p*4 + f*9 + c*4 }')"

    nutrition="Calories:${kcal}${separator}Protein:${protein}g${separator}Fat:${fat}g${separator}Carbs:${carbs}g"

    meal="${padding}${meal}${padding}"

    nutrition="${padding}${nutrition}${padding}"
}

render() {
    magick \
        "${input}" \
        -fill white \
        -undercolor "${UNDERCOLOR}" \
        -gravity south \
        -font "${FONT_SANS}" \
        -pointsize "${meal_ps}" \
        -annotate +0+"${meal_y}" "${meal}" \
        -font "${FONT_MONO}" \
        -pointsize "${nutrition_ps}" \
        -annotate +0+"${nutrition_y}" "${nutrition}" \
        -quality 100 \
        "${output}"
}

finalize() {
    file "$(readlink -f "${output}")"
    printf 'Created: %s\n' "$(readlink -f "${output}")"
}

main() {
    parse_arguments "$@"
    validate
    prepare
    render
    finalize
}

main "$@"
