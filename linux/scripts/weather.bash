#!/usr/bin/env bash

if [[ "$#" -eq 0 ]]; then
    builtin printf "Usage:\n%s <city/pincode> [--force]\n" "${0##*/}"
    builtin exit 1
fi

FORCE=0

if [[ "${*: -1}" == "--force" ]]; then
    FORCE=1
    builtin set -- "${@:1:$#-1}"
fi

SEPARATOR=':'

for LOCATION in "${@}"; do
    CACHE_FILE="/tmp/weather-${LOCATION}.cache"

    if [[ "${FORCE}" -eq 0 ]] \
        && [[ -f "${CACHE_FILE}" ]] \
        && [[ "$(/usr/bin/find "${CACHE_FILE}" -mmin -15 2>/dev/null)" ]]; then
        /usr/bin/cat "${CACHE_FILE}"
    else
        IFS='|' builtin read -r WEATHER TEMPERATURE HUMIDITY RAINFALL WIND PRESSURE UVINDEX < <(
            /usr/bin/curl \
                -s \
                "https://wttr.in/${LOCATION}?format=%C|%t|%h|%p|%w|%P|%u"
        )

        declare -a DATA=(
            "Location|${LOCATION}"
            "Weather|${WEATHER}"
            "Temperature|${TEMPERATURE}"
            "Humidity|${HUMIDITY}"
            "Pressure|${PRESSURE}"
            "UV Index|${UVINDEX}"
            "Rainfall|${RAINFALL}"
            "Wind|${WIND}"
        )

        {
            for ITEM in "${DATA[@]}"; do
                IFS='|' builtin read -r KEY VALUE <<< "${ITEM}"

                builtin printf "%s%s %s\n" \
                    "${KEY}" \
                    "${SEPARATOR}" \
                    "${VALUE}"
            done
        } \
        | /usr/bin/column \
            -s "${SEPARATOR}" \
            -t \
            -o "${SEPARATOR}" \
            -R 1 \
        | /usr/bin/tee "${CACHE_FILE}"
    fi

    builtin echo
done
