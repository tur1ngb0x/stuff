# #!/usr/bin/env bash

while true; do
    choice="$(zenity --list \
        --title="Session Menu" \
        --text="Session Menu" \
        --radiolist \
        --height=220 \
        --column="Select" \
        --column="Action" \
        FALSE "Logout" \
        FALSE "Rescue" \
        FALSE "Reboot" \
        FALSE "Firmware" \
        FALSE "Poweroff")"

    [ -z "${choice}" ] && exit 0

    zenity --question \
        --title="Confirm" \
        --text="${choice}\nDo you want to proceed?\n" \
        --timeout=5

    [ $? -ne 0 ] && continue

    case "${choice}" in
        "Firmware") systemctl reboot --firmware-setup ;;
        "Logout")   loginctl terminate-user "${USER}" ;;
        "Poweroff") systemctl poweroff ;;
        "Reboot")   systemctl reboot ;;
        "Rescue")   systemctl rescue ;;
    esac

    exit 0
done
