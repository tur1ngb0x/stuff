setfont ter-122n

pacman -Sy --noconfirm --needed openssh wget curl git

systemctl enable --now iwd

builtin printf '%s' 'Enter SSID name: '

builtin read -r ssid

iwctl station wlan0 connect "${ssid}"

ping -c5 google.com

timedatectl set-timezone Asia/Kolkata --adjust-system-clock

passwd

pacman -Sy --noconfirm --needed openssh wget curl git

systemctl enable --now sshd

builtin printf '%s\n' 'PermitRootLogin yes' | tee /etc/ssh/sshd_config

systemctl restart sshd

builtin printf '%s\n' 'SSH READY: ssh -p 2222 root@127.0.0.1'
