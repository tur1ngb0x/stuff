#!/bin/bash

{ builtin set -euxo pipefail; } &>/dev/null

/usr/bin/setfont ter-122n

/usr/bin/pacman -Sy --noconfirm --needed openssh wget curl git

/usr/bin/systemctl enable --now iwd

builtin printf '%s' 'Enter SSID name: '

builtin read ssid

/usr/bin/iwctl station wlan0 connect "${ssid}"

/usr/bin/ping -c5 google.com

/usr/bin/timedatectl set-timezone Asia/Kolkata --adjust-system-clock

/usr/bin/passwd

/usr/bin/pacman -Sy --noconfirm --needed openssh wget curl git

/usr/bin/systemctl enable --now sshd

builtin printf '%s\n' 'PermitRootLogin yes' | /usr/bin/tee /etc/ssh/sshd_config

/usr/bin/systemctl restart sshd

builtin printf '%s\n' 'SSH READY: ssh -p 2222 root@127.0.0.1'

{ builtin set +euxo pipefail; } &>/dev/null
