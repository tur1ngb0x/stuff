#!/usr/bin/env bash

# install package
sudo apt install samba || sudo dnf install samba || sudo pacman -S samba

# add user to group
sudo groupadd -f sambashare && sudo usermod -aG sambashare "${USER}"

# backup config
sudo cp -fv /etc/samba/smb.conf /etc/samba/smb.conf.bak

# create config
cat << EOF | sudo tee /etc/samba/smb.conf; clear; testparm -s
#######################################################################################################################
[global]
#######################################################################################################################
# server
#######################################################################################################################
server string = $(hostnamectl hostname)-samba-server
server role = standalone server
server multi channel support = yes
workgroup = WORKGROUP
logging = systemd
#######################################################################################################################
# security
#######################################################################################################################
client smb encrypt = off
server smb encrypt = off
server signing = disabled
client signing = disabled
client max protocol = SMB3
client min protocol = SMB3
#######################################################################################################################
# i/o
#######################################################################################################################
use sendfile = yes
strict locking = no
#######################################################################################################################
# share
#######################################################################################################################
[$(hostnamectl hostname)-samba-server]
path = /home/${USER}
valid users = ${USER}
writable = yes
comment = $(hostnamectl hostname)-samba-server
force group = ${USER}
force user = ${USER}
fstype = Samba
#######################################################################################################################
EOF

# set password
sudo smbpasswd -a "${USER}" && sudo smbpasswd -e "${USER}"

# enable service
sudo systemctl enable --now smbd.service nmbd.service || sudo systemctl enable --now smb.service nmb.service

# check service
sudo systemctl --no-pager status smbd.service nmbd.service || sudo systemctl --no-pager status smb.service nmb.service

# restart service
sudo systemctl restart --now smbd.service nmbd.service || sudo systemctl restart --now smb.service nmb.service
