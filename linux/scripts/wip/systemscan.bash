#!/usr/bin/env bash

printf "\n\033[1;38;5;255;48;5;160m ---- FAILED UNITS ---- \033[0m\n"
/usr/bin/systemctl --failed --no-legend

printf "\n\033[1;38;5;255;48;5;160m ---- JOURNAL (CURRENT BOOT) ---- \033[0m\n"
/usr/bin/journalctl -p 3 -b --no-pager

printf "\n\033[1;38;5;255;48;5;160m ---- JOURNAL (PREVIOUS BOOT) ---- \033[0m\n"
/usr/bin/journalctl -p 3 -b -1 --no-pager

printf "\n\033[1;38;5;232;48;5;214m ---- DISK ---- \033[0m\n"
/usr/bin/df -h /efi / /home

printf "\n\033[1;38;5;232;48;5;214m ---- SENSORS ---- \033[0m\n"
/usr/bin/sensors

printf "\n\033[1;38;5;232;48;5;214m ---- INTEGRITY ---- \033[0m\n"
sudo /usr/bin/pacman --query --check |
    /usr/bin/grep -v '0 missing files$'

printf "\n\033[1;38;5;232;48;5;214m ---- PACCHECK ---- \033[0m\n"
sudo /usr/bin/paccheck --quiet

printf "\n\033[1;38;5;232;48;5;45m ---- *.PAC* ---- \033[0m\n"

LC_ALL=C /usr/bin/find / \
    -type d \
    \( \
        -path /proc \
        -o -path /sys \
        -o -path /run \
        -o -path /dev \
    \) \
    -prune \
    -o \
    -type f \
    \( \
        -iname '*.pacnew' \
        -o -iname '*.pacsave' \
    \) \
    -print 2>/dev/null |
    LC_ALL=C /usr/bin/sort

printf "\n\033[1;38;5;232;48;5;45m ---- KERNELS ---- \033[0m\n"

printf "running: %s\n" "$(/usr/bin/uname -r)"

printf "installed: %s\n" "$(
    /usr/bin/pacman --query --quiet |
        /usr/bin/grep '^linux' |
        /usr/bin/grep -vE 'firmware|headers' |
        /usr/bin/xargs
)"

printf "\n\033[1;38;5;232;48;5;154m ---- PACKAGES ---- \033[0m\n"

pacman_count="$(/usr/bin/pacman --query --quiet | /usr/bin/wc -l)"
arch_count="$(/usr/bin/pacman --query --quiet --native | /usr/bin/wc -l)"

orphans_packages="$(/usr/bin/pacman --query --quiet --deps --unrequired | /usr/bin/xargs)"
orphans_count="$(builtin printf "%s\n" "${orphans_packages}" | /usr/bin/wc -w)"

foreign_packages="$(/usr/bin/pacman --query --foreign | /usr/bin/awk '{print $1}' | /usr/bin/xargs)"
foreign_count="$(builtin printf "%s\n" "${foreign_packages}" | /usr/bin/wc -w)"

flatpak_count="$(/usr/bin/flatpak list --all | /usr/bin/wc -l)"

printf "pacman: %s\n" "${pacman_count}"
printf "arch: %s\n" "${arch_count}"

if [[ "${orphans_count}" -gt 0 ]]; then
    printf "orphans: %s (%s)\n" "${orphans_count}" "${orphans_packages}"
fi

if [[ "${foreign_count}" -gt 0 ]]; then
    printf "foreign: %s (%s)\n" "${foreign_count}" "${foreign_packages}"
fi

if [[ "${flatpak_count}" -gt 0 ]]; then
    printf "flatpak: %s\n" "${flatpak_count}"
fi
