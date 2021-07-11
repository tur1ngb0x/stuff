#!/usr/bin/env bash

# install samba
sudo apt update && sudo apt install -y samba

# check installation
whereis samba

# create samba folder
# mkdir -pv "$HOME/element"

# backup samba config file
sudo cp -iv "/etc/samba/smb.conf" "/etc/samba/smb.conf.bak"

# Edit smb.conf
cat << EOF | sudo tee "/etc/samba/smb.conf"

[global]
workgroup = WORKGROUP
server string = %h server (Samba, Linux)
log file = /var/log/samba/log.%m
max log size = 1000
logging = file
panic action = /usr/share/samba/panic-action %d
server role = standalone server
obey pam restrictions = yes
unix password sync = yes
passwd program = /usr/bin/passwd %u
passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n 
pam password change = yes
map to guest = bad user
usershare allow guests = yes

[starlabs]
comment = starlabs
path = "$HOME"
valid users = "$USER"
force user = "$USER"
read only = no
writeable = yes
browsable = yes
create mask = 0755
directory mask = 0755

[elements]
comment = elements
path = /mnt/elements
valid users = "$USER"
force user = "$USER"
read only = no
writeable = yes
browsable = yes
create mask = 0755
directory mask = 0755
EOF


# allow samba through firewall
sudo ufw allow samba

# create samba group
sudo groupadd samba

# add user to samba group
sudo gpasswd -a "$USER" samba
# sudo usermod -aG samba "$USER"

# set group ownership
# sudo chgrp sambashare "$HOME"

# set samba password
sudo smbpasswd -a "$USER"

# restart samba service
sudo systemctl restart nmbd smbd

# check samba syntax errors
testparm
