#!/usr/bin/env bash

readonly EXCLUDE=':not(.codicon):not([class*=codicon-]):not([class*=file-icon])'
readonly FONT='"IosevkaTerm Nerd Font Mono",monospace'
readonly PATCH="*${EXCLUDE}{font-family:${FONT}!important;}"
readonly STAMP="$(/usr/bin/date +%Y%m%d-%H%M%S)"

readonly FILES=(
    "/opt/visual-studio-code/resources/app/out/vs/sessions/sessions.desktop.main.css"
    "/opt/visual-studio-code/resources/app/out/vs/workbench/workbench.desktop.main.css"
    "/usr/lib/code/out/vs/sessions/sessions.desktop.main.css"
    "/usr/lib/code/out/vs/workbench/workbench.desktop.main.css"
)

for f in "${FILES[@]}"; do
    if [[ ! -s "${f}" ]]; then
        builtin printf 'Skipping missing or empty file: %s\n' "${f}" >&2
        builtin continue
    fi

    if ! /usr/bin/sudo /usr/bin/grep -Fqx -- "${PATCH}" "${f}"; then
        printf 'Patch %s? [N/y] ' "${f}"
        read -r reply

        case "${reply}" in
            [Yy]|[Yy][Ee][Ss])
                /usr/bin/sudo /usr/bin/cp \
                    --verbose \
                    --preserve=all \
                    -- "${f}" "${f}.${STAMP}.bak"

                printf '\n%s\n' "${PATCH}" |
                    /usr/bin/sudo /usr/bin/tee -a -- "${f}" >/dev/null
                ;;
            *)
                continue
                ;;
        esac
    fi

    /usr/bin/sudo /usr/bin/grep -FHxn --color=auto -- "${PATCH}" "${f}"
done
