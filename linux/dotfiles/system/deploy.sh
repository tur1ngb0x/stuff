#!/usr/bin/env bash

# APT
/usr/bin/sudo /usr/bin/install -v -D ./etc/apt/apt.conf.d/99-slim-apt.conf /etc/apt/apt.conf.d/99-slim-apt.conf

# APPARMOUR
/usr/bin/sudo /usr/bin/install -v -D ./etc/sysctl.d/99-kernel-apparmour /etc/sysctl.d/99-kernel-apparmour

# BASH
/usr/bin/sudo /usr/bin/install -v -D ./etc/bash.bashrc /etc/bash.bashrc

# BRAVE
/usr/bin/sudo /usr/bin/install -v -D ./etc/browser/policies/managed/brave.json /etc/brave/policies/managed/brave.json

# DOCKER
/usr/bin/sudo /usr/bin/mkdir -v -p /home/docker
/usr/bin/sudo /usr/bin/install -v -D ./etc/docker/daemon.json /etc/docker/daemon.json

# FONTS
/usr/bin/sudo /usr/bin/install -v -D ./../user/.config/fontconfig/fonts.conf /etc/fonts/local.conf
/usr/bin/sudo /usr/bin/ln -f -s -v /usr/share/fontconfig/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d/10-sub-pixel-rgb.conf
/usr/bin/sudo /usr/bin/ln -f -s -v /usr/share/fontconfig/conf.avail/10-hinting-slight.conf /etc/fonts/conf.d/10-hinting-slight.conf
/usr/bin/sudo /usr/bin/ln -f -s -v /usr/share/fontconfig/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d/11-lcdfilter-default.conf

# NETWORK
/usr/bin/sudo /usr/bin/install -v -D ./etc/NetworkManager/conf.d/99-custom.conf /etc/NetworkManager/conf.d/99-custom.conf

# SUDO
/usr/bin/sudo /usr/bin/install -v -D ./etc/sudoers.d/99-custom /etc/sudoers.d/99-custom

# WSL
/usr/bin/sudo /usr/bin/install -v -D ./etc/wsl.conf /etc/wsl.conf
