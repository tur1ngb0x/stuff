#!/usr/bin/env bash

LC_ALL=C

function fetch_data () {
    local string="${1}"
    local location="${2}"
    if command -v curl &> /dev/null; then
        command -p curl -4 -s -L "wttr.in/${location}?format=${string}"
    elif command -v wget &> /dev/null; then
        command -p wget -4 -q -O- "wttr.in/${location}?format=${string}"
    else
        print_na
    fi
}

function get_now {
    if command -v date &> /dev/null; then
        printf '%s' "$(command -p date +'%Y-%m-%d %a %H:%M:%S')"
    else
        print_na
    fi
}

function get_location {
    local location_raw; location_raw="$(fetch_data '%l' "${1}")"
    printf '%s' "${location_raw//+/ }"
}

function get_weather {
    local weather_raw; weather_raw="$(fetch_data '%C' "${1}")"
    printf '%s' "$(echo "${weather_raw}" | sed -r 's/(^|[[:space:],])([a-z])/\1\u\2/g')"
}

function get_temperature {
    local temp_raw; temp_raw="$(fetch_data '%t' "${1}")"
    local temp_value="${temp_raw//°C/}"; temp_value="${temp_value//+/}"
    local category="?"

    if (( temp_value < 0 )); then
        category="Sub Zero"
    elif (( temp_value >= 0 && temp_value <= 10 )); then
        category="Cold"
    elif (( temp_value >= 11 && temp_value <= 20 )); then
        category="Cool"
    elif (( temp_value >= 21 && temp_value <= 30 )); then
        category="Warm"
    elif (( temp_value >= 31 && temp_value <= 40 )); then
        category="Hot"
    elif (( temp_value > 40 )); then
        category="Very Hot"
    fi
    printf '%s (%s)' "${temp_raw}" "${category}"
}

function get_feelslike {
    local feels_raw
    feels_raw="$(fetch_data '%f' "${1}")"
    local feels_value="${feels_raw//°C/}"
    feels_value="${feels_value//+/}"
    local category="?"

    if (( feels_value < 0 )); then
        category="Sub Zero"
    elif (( feels_value >= 0 && feels_value <= 10 )); then
        category="Cold"
    elif (( feels_value >= 11 && feels_value <= 20 )); then
        category="Cool"
    elif (( feels_value >= 21 && feels_value <= 30 )); then
        category="Warm"
    elif (( feels_value >= 31 && feels_value <= 40 )); then
        category="Hot"
    elif (( feels_value > 40 )); then
        category="Very Hot"
    fi
    printf '%s (%s)' "${feels_raw}" "${category}"
}

function get_humidity {
    local humidity_raw
    humidity_raw="$(fetch_data '%h' "${1}")"
    local humidity_value="${humidity_raw//%/}"
    local category="?"

    if (( humidity_value >= 0 && humidity_value <= 20 )); then
        category="Low"
    elif (( humidity_value >= 21 && humidity_value <= 40 )); then
        category="Moderate"
    elif (( humidity_value >= 41 && humidity_value <= 60 )); then
        category="High"
    elif (( humidity_value >= 61 && humidity_value <= 80 )); then
        category="Very High"
    elif (( humidity_value >= 81 && humidity_value <= 100 )); then
        category="Extreme"
    fi
    printf '%s (%s)' "${humidity_raw}" "${category}"
}

function get_rain {
    local rain_raw
    rain_raw="$(fetch_data '%p' "${1}")"
    local rain_value="${rain_raw//mm/}"
    rain_value=$(echo "${rain_value} * 10" | bc 2>/dev/null)
    rain_value=$(printf "%.0f" "${rain_value}" 2>/dev/null)

    local category="?"
    if [ -z "${rain_value}" ]; then
        category="?"
    elif (( rain_value == 0 )); then
        category="None"
    elif (( rain_value >= 1 && rain_value < 75 )); then
        category="Light"
    elif (( rain_value >= 75 && rain_value < 225 )); then
        category="Moderate"
    elif (( rain_value >= 225 && rain_value < 450 )); then
        category="Heavy"
    elif (( rain_value >= 450 )); then
        category="Very Heavy"
    fi
    printf '%s (%s)' "${rain_raw}" "${category}"
}

function get_wind {
    local wind_raw
    wind_raw="$(fetch_data '%w' "${1}")"
    local wind_display="${wind_raw//[↗↘↙↖→←↑↓]/}"
    wind_display="${wind_display//km\/h/kmph}"

    local wind_direction="?"
    case "${wind_raw}" in
        *→*) wind_direction="East" ;;
        *←*) wind_direction="West" ;;
        *↑*) wind_direction="North" ;;
        *↓*) wind_direction="South" ;;
        *↗*) wind_direction="North East" ;;
        *↘*) wind_direction="South East" ;;
        *↙*) wind_direction="South West" ;;
        *↖*) wind_direction="North West" ;;
    esac
    printf '%s (%s)' "${wind_display}" "${wind_direction}"
}

function get_pressure {
    local pressure_raw
    pressure_raw="$(fetch_data '%P' "${1}")"
    local pressure_value="${pressure_raw%hPa}"
    local category="?"

    if (( pressure_value < 1000 )); then
        category="Very Low"
    elif (( pressure_value >= 1000 && pressure_value <= 1011 )); then
        category="Low"
    elif (( pressure_value >= 1012 && pressure_value <= 1014 )); then
        category="Normal"
    elif (( pressure_value >= 1015 && pressure_value <= 1025 )); then
        category="High"
    elif (( pressure_value > 1025 )); then
        category="Very High"
    fi
    printf '%s (%s)' "${pressure_raw}" "${category}"
}

function get_uv_index {
    local uv_raw
    uv_raw="$(fetch_data '%u' "${1}")"
    local uv_value="${uv_raw}"
    local category="?"

    if (( uv_value >= 0 && uv_value <= 2 )); then
        category="Low"
    elif (( uv_value >= 3 && uv_value <= 5 )); then
        category="Moderate"
    elif (( uv_value >= 6 && uv_value <= 7 )); then
        category="High"
    elif (( uv_value >= 8 && uv_value <= 10 )); then
        category="Very High"
    elif (( uv_value >= 11 )); then
        category="Extreme"
    fi
    printf '%s (%s)' "${uv_raw}" "${category}"
}


cat << EOF
Location : $(get_location "${location}")
Weather : $(get_weather "${location}")
Temperature: $(get_temperature "${location}" | cut -d' ' -f1)
Humidity : $(get_humidity "${location}" | cut -d' ' -f1)
Rain : $(get_rain "${location}" | cut -d' ' -f1)
Wind : $(get_wind "${location}" | cut -d' ' -f1)
EOF
