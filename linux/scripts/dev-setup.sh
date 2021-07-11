#!/usr/bin/env bash

pkg-install() { /usr/bin/sudo /usr/bin/apt install -y --dry-run "$@"; }
pip-install() { /usr/bin/sudo /usr/bin/pip3 install --ignore-installed "$@"; }
text () { /usr/bin/printf "\n\n\nInstalling $1:\n"; }

text "Essentials"
pkg-install wget curl apt-transport-https
pkg-install ca-certificates gnupg lsb-release
pkg-install software-properties-gtk software-properties-common
pkg-install vim nano synaptic
pkg-install git git-extras bash-completion

text "C/C++"
pkg-install build-essential clang-format

text "Python"
pkg-install python3-pip python3-setuptools python3-wheel

text "Python Packages"
pip-install tuir
pip-install ps_mem
pkg-install ffmpeg && pip-install youtube-dl
pkg-install msr-tools && pip-install undervolt

text "Java"
pkg-install default-jdk default-jre

text "Firewall"
pkg-install ufw gufw
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw status verbose

text "File Archivers"
pkg-install atool p7zip-full p7zip-rar

text "File Systems"
pkg-install exfat-utils exfat-fuse ntfs-3g

text "Disk Tools"
pkg-install gparted mtools dosfstools smartmontools

text "Android Tools"
pkg-install android-sdk-platform-tools android-sdk-platform-tools-common

text "Network Tools"
pkg-install net-tools traceroute openssh-server

text "Misc Tools"
pkg-install tree mlocate inxi

text "Ubuntu Restricted Extras"
pkg-install ubuntu-restricted-addons libavcodec-extra unrar
