brave-pwa-icon-check() {
    local dir="${HOME}/.local/share/applications"
    local f
    local icon
    local wmclass

    local bright_red="\033[1;31m"
    local reset="\033[0m"

    printf "PWAs with StartupWMClass != Icon\n"

    for f in "${dir}"/*brave*.desktop; do
        if [[ -f "${f}" ]]; then
            icon="$(grep -m1 "^Icon=" "${f}" | cut -d= -f2- || true)"
            wmclass="$(grep -m1 "^StartupWMClass=" "${f}" | cut -d= -f2- || true)"

            if [[ "${wmclass}" != "${icon}" ]]; then
                printf "%b%s%b\n" "${bright_red}" "${f}" "${reset}"
            fi
        fi
    done
}; brave-pwa-icon-check
