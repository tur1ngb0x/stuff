#!/usr/bin/env bash

for fx in nautilus dolphin nemo thunar caja pcmanfm ranger lf xdg-open; do
    if command -v "${fx}" &> /dev/null; then
        fxcmd="${fx}"
        builtin break
    fi
done

if [[ -z "${fxcmd}" ]]; then
    command -p echo "Supported file managers: nautilus dolphin nemo thunar caja pcmanfm ranger lf xdg-open"
    builtin exit
fi

echo "${fxcmd} ${*} &>/dev/null &"
nohup "${fxcmd}" "${@}" &>/dev/null &
