#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly EXCLUDE=':not(.codicon):not([class*=codicon-]):not([class*=file-icon])'
readonly FONT='"IosevkaTerm Nerd Font Mono",monospace'
readonly PATCH="*${EXCLUDE}{font-family:${FONT}!important;}"
readonly STAMP="$(/usr/bin/date -- '+%Y%m%d-%H%M%S')"

for v in EXCLUDE FONT PATCH STAMP; do
    [[ -z "${!v:-}" ]] && { builtin printf -- '%s is unset or empty\n' "${v}"; builtin exit 1; }
done

readonly FILES=(
    "/opt/visual-studio-code/resources/app/out/vs/sessions/sessions.desktop.main.css"
    "/opt/visual-studio-code/resources/app/out/vs/workbench/workbench.desktop.main.css"
)

for f in "${FILES[@]}"; do
    [[ ! -s "${f}" ]] && { builtin printf -- 'Invalid or empty file: %s\n' "${f}" && builtin exit 1; }
    /usr/bin/sudo /usr/bin/cp --verbose --preserve=all -- "${f}" "${f}.${STAMP}.bak"
    /usr/bin/sudo /usr/bin/grep -Fqx -- "${PATCH}" "${f}" || { builtin printf -- '\n%s\n' "${PATCH}" | /usr/bin/sudo /usr/bin/tee -a -- "${f}" > /dev/null; }
    /usr/bin/sudo /usr/bin/grep -FHxn --color=auto -- "${PATCH}" "${f}"
done
