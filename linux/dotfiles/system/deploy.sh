# APT
sudo install -v -D ./etc/apt/apt.conf.d/99-slim-apt.conf /etc/apt/apt.conf.d/99-slim-apt.conf

# APPARMOUR
sudo install -v -D ./etc/sysctl.d/99-kernel-apparmour /etc/sysctl.d/99-kernel-apparmour

# BASH
sudo install -v -D ./etc/bash.bashrc /etc/bash.bashrc
sudo install -v -D ./etc/bash.bashrc /etc/bashrc

# BRAVE
sudo install -v -D ./etc/browser/policies/managed/brave.json /etc/brave/policies/managed/brave.json

# DOCKER
sudo mkdir -v -p /home/docker
sudo install -v -D ./etc/docker/daemon.json /etc/docker/daemon.json

# FONTS
sudo install -v -D ./../user/.config/fontconfig/fonts.conf /etc/fonts/local.conf
sudo ln -f -s -v /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/10-sub-pixel-rgb.conf
sudo ln -f -s -v /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/10-hinting-slight.conf
sudo ln -f -s -v /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/11-lcdfilter-default.conf

# NETWORK
sudo install -v -D ./etc/NetworkManager/conf.d/99-custom.conf /etc/NetworkManager/conf.d/99-custom.conf

# SUDO
sudo install -v -D ./etc/sudoers.d/99-custom /etc/sudoers.d/99-custom

# WSL
sudo install -v -D ./etc/wsl.conf /etc/wsl.conf
