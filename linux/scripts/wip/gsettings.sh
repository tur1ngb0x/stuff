#!/usr/bin/env bash

set -euo pipefail

schema="${1:-}"
key="${2:-}"
value="${3:-}"

# return if arguments are missing
if [ -z "${schema}" ] || [ -z "${key}" ] || [ -z "${value}" ]; then
    echo "usage: gsettings.sh <SCHEMA> <KEY> <VALUE>" >&2
    exit 2
fi

# return if schema is missing/invalid
if ! gsettings list-schemas | grep -Fxq "${schema}"; then
    echo "gsettings.sh: schema not found: ${schema}" >&2
    exit 3
fi

# return if key is missing/invalid
if ! gsettings list-keys "${schema}" | grep -Fxq "${key}"; then
    echo "gsettings.sh: key not found: ${schema} ${key}" >&2
    exit 4
fi

# get current value
current="$(gsettings get "${schema}" "${key}")" || exit 5

# return if already correct (idempotent)
if [ "${current}" = "${value}" ]; then
    exit 0
fi

# reset key to default
gsettings reset "${schema}" "${key}" || exit 6

# apply desired value (fails if invalid type/format)
if ! gsettings set "${schema}" "${key}" "${value}"; then
    echo "gsettings.sh: invalid value for ${schema} ${key}: ${value}" >&2
    exit 7
fi

# verify applied value
after="$(gsettings get "${schema}" "${key}")" || exit 8
if [ "${after}" != "${value}" ]; then
    echo "gsettings.sh: value mismatch after set: ${schema} ${key}" >&2
    exit 9
fi

exit 0
