#!/usr/bin/env bash

declare -a fx_list=(nautilus dolphin nemo thunar caja pcmanfm ranger lf xdg-open)

for fx in "${fx_list[@]}"; do
    if [[ -x "/usr/bin/${fx}" ]]; then
        fxcmd="/usr/bin/${fx}"
        break
    fi
done

if [[ -z "${fxcmd}" ]]; then
    builtin echo "Supported file managers: ${fx_list[*]}"
    builtin exit 1
fi

builtin echo "${fxcmd} ${*} &>/dev/null &"
/usr/bin/nohup "${fxcmd}" "${@}" &>/dev/null &
