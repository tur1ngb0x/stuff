#!/usr/bin/env bash

format_data () {
    /usr/bin/column \
        -s '|' \
        -o '|' \
        -R 1,2,3,4,5,6,7,8,9 \
        -t
}

color_data() {
    # Primary colors
    # Red          : (255   0   0)
    # Green        : (  0 255   0)
    # Blue         : (  0   0 255)
    # Cyan         : (  0 255 255)
    # Magenta      : (255   0 255)
    # Yellow       : (255 255   0)
    # Orange       : (255 127   0)
    # Chartreuse   : (127 255   0)
    # Spring Green : (  0 255 127)
    # Azure        : (  0 127 255)
    # Violet       : (127   0 255)
    # Rose         : (255   0 127)

    # Gradient start color (RGB)
    local -a COLOR_START=(255 255 255)
    # Gradient end color (RGB)
    local -a COLOR_END=(255 255 255)

    # Input lines
    builtin mapfile -t LINES

    # Index of the last line
    local LAST=$(( ${#LINES[@]} - 1 ))

    # Current RGB color components
    local R G B

    # Current line index
    local i

    for ((i = 0; i <= LAST; i++)); do
        R=$(( COLOR_START[0] + (COLOR_END[0] - COLOR_START[0]) * i / LAST ))
        G=$(( COLOR_START[1] + (COLOR_END[1] - COLOR_START[1]) * i / LAST ))
        B=$(( COLOR_START[2] + (COLOR_END[2] - COLOR_START[2]) * i / LAST ))

        builtin printf '\e[38;2;%d;%d;%dm%s\e[0m\n' \
            "${R}" \
            "${G}" \
            "${B}" \
            "${LINES[i]}"
    done
}

transpose_data() {
    local -a ROWS
    local -a FIELDS
    local ROW COL

    builtin mapfile -t ROWS

    for ROW in "${!ROWS[@]}"; do
        IFS='|' builtin read -r -a FIELDS <<< "${ROWS[ROW]}"

        for COL in "${!FIELDS[@]}"; do
            TABLE["${COL},${ROW}"]="${FIELDS[COL]}"
        done

        (( COLS < ${#FIELDS[@]} )) && COLS=${#FIELDS[@]}
    done

    for ((COL = 0; COL < COLS; COL++)); do
        for ((ROW = 0; ROW < ${#ROWS[@]}; ROW++)); do
            builtin printf '%s' "${TABLE["${COL},${ROW}"]}"

            if (( ROW != ${#ROWS[@]} - 1 )); then
                builtin printf '|'
            fi
        done

        builtin printf '\n'
    done
}

declare_data () {
    declare -ga LOCATIONS=("$@")

    declare -ga FIELDS=(
        "Location"
        "Weather"
        "Temperature"
        "Humidity"
        "Pressure"
        "UV Index"
        "Rainfall"
        "Wind"
    )

    declare -gA TABLE
}

get_data () {
    local LOCATION
    local WEATHER
    local TEMPERATURE
    local HUMIDITY
    local RAINFALL
    local WIND
    local PRESSURE
    local UVINDEX

    for LOCATION in "${LOCATIONS[@]}"; do
        IFS='|' builtin read -r \
            WEATHER \
            TEMPERATURE \
            HUMIDITY \
            RAINFALL \
            WIND \
            PRESSURE \
            UVINDEX \
            < <(
                /usr/bin/curl \
                    --ipv4 \
                    --silent \
                    "https://wttr.in/${LOCATION}?format=%C|%t|%h|%p|%w|%P|%u"
            )

        TABLE["Location,${LOCATION}"]="${LOCATION}"
        TABLE["Weather,${LOCATION}"]="${WEATHER}"
        TABLE["Temperature,${LOCATION}"]="${TEMPERATURE}"
        TABLE["Humidity,${LOCATION}"]="${HUMIDITY}"
        TABLE["Pressure,${LOCATION}"]="${PRESSURE}"
        TABLE["UV Index,${LOCATION}"]="${UVINDEX}"
        TABLE["Rainfall,${LOCATION}"]="${RAINFALL}"
        TABLE["Wind,${LOCATION}"]="${WIND}"
    done
}

print_rows () {
    local FIELD
    local LOCATION

    {
        for FIELD in "${FIELDS[@]}"; do
            builtin printf '| %s ' "${FIELD}"

            for LOCATION in "${LOCATIONS[@]}"; do
                builtin printf '| %s ' "${TABLE["${FIELD},${LOCATION}"]}"
            done

            builtin printf '|\n'
        done
    }
}

print_columns() {
    local LOCATION
    local FIELD

    {
        builtin printf '|'

        for FIELD in "${FIELDS[@]}"; do
            builtin printf ' %s |' "${FIELD}"
        done

        builtin printf '\n'

        for LOCATION in "${LOCATIONS[@]}"; do
            builtin printf '| %s ' "${LOCATION}"

            for FIELD in "${FIELDS[@]:1}"; do
                builtin printf '| %s ' "${TABLE["${FIELD},${LOCATION}"]}"
            done

            builtin printf '|\n'
        done
    }
}

main() {
    if [[ "$#" -eq 0 ]]; then
        builtin printf "Usage:\n%s <city/pincode> [<city/pincode> ...]\n" "${0##*/}"
        builtin exit 1
    fi

    declare_data "$@"

    get_data

    if (( $# <= 2 )); then
        print_rows | format_data
    else
        print_columns | format_data
    fi
}

main "$@"
