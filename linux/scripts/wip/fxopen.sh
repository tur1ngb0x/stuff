fx_list=(nautilus dolphin nemo thunar caja pcmanfm ranger lf xdg-open)

for fx in "${fx_list[@]}"; do
    if command -v "${fx}" &>/dev/null; then
        fxcmd="${fx}"
        break
    fi
done

if [[ -z "${fxcmd}" ]]; then
    command -p echo "Supported file managers: ${fx_list[*]}"
    exit 1
fi

echo "${fxcmd} ${*} &>/dev/null &"
nohup "${fxcmd}" "${@}" &>/dev/null &
