#!/usr/bin/env bash

declare -a fxs=(
    nautilus          # GNOME Files
    dolphin           # KDE Dolphin
    nemo              # Cinnamon file manager
    thunar            # XFCE file manager
    caja              # MATE file manager
    pcmanfm           # LXDE file manager
    pcmanfm-qt        # LXQt file manager
    spacefm           # Multi-panel file manager
    zzzfm             # SpaceFM fork
    krusader          # Dual-pane file manager
    doublecmd         # Cross-platform dual-pane manager
    xfe               # X File Explorer
    rox               # ROX-Filer
    xdg-open          # Generic opener (fallback)
)

fxcmd=''

for fx in "${fxs[@]}"; do
    if [[ -x "/usr/bin/${fx}" ]]; then
        fxcmd="/usr/bin/${fx}"
        break
    fi
done

if [[ -z "${fxcmd}" ]]; then
    builtin printf 'Supported file managers: %s\n' "${fxs[*]}"
    builtin exit 1
fi

if (( $# == 0 )); then
    builtin set -- .
fi

if [[ "${1}" == "." && $# -eq 1 ]]; then
    builtin printf '+ /usr/bin/setsid %s %s\n' "${fxcmd}" "${PWD}"
else
    builtin printf '+ /usr/bin/setsid %s %s\n' "${fxcmd}" "$*"
fi

/usr/bin/setsid "${fxcmd}" "${@}" </dev/null >/dev/null 2>&1 &

builtin printf '+ builtin disown\n'
builtin disown
