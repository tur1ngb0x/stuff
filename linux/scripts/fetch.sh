#!/usr/bin/env bash

printf \
    "%s\n" \
    " "

printf \
    "\033[1;38;2;0;200;200m DISTRO  \033[0m: %s\n" \
    "$(sed --silent 's/^PRETTY_NAME="\([^"]*\)"/\1/p' /etc/os-release 2>/dev/null)"

printf \
    "\033[1;38;2;64;150;200m KERNEL  \033[0m: %s\n" \
    "$(uname --kernel-release 2>/dev/null)"

printf \
    "\033[1;38;2;128;100;200m UPTIME  \033[0m: %s\n" \
    "$(uptime --pretty 2>/dev/null | sed 's/up //g; s/,//g; s/ hour/hr/g; s/ minutes/min/g' 2>/dev/null)"

printf \
    "\033[1;38;2;170;60;190m   DISK  \033[0m: %s/%s GiB\n" \
    "$(df / 2>/dev/null | awk 'FNR==2 {printf "%.2f\n", $3/1024/1024}')" \
    "$(df / 2>/dev/null | awk 'FNR==2 {printf "%.2f\n", $2/1024/1024}')" 2>/dev/null

printf \
    "\033[1;38;2;200;20;170m    RAM  \033[0m: %s/%s GiB\n" \
    "$(free | awk 'FNR==2 {printf "%.2f\n", $3/1024/1024}')" \
    "$(free | awk 'FNR==2 {printf "%.2f\n", $2/1024/1024}')" 2>/dev/null

printf \
    "%s\n" \
    " " 2>/dev/null
