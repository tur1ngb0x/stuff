#!/usr/bin/env bash

# virt-manager : groups
sudo groupadd -f kvm
sudo usermod -aG kvm "${USER}"
sudo groupadd -f libvirt
sudo usermod -aG libvirt "${USER}"

# virt-manager : virsh
sudo virsh net-autostart default
sudo virsh net-start default

# virt-manager : libvirt
cat << EOF | sudo tee -a /etc/libvirt/libvirtd.conf
unix_sock_group = 'libvirt'
unix_sock_ro_perms = '0770'
unix_sock_rw_perms = '0770'
auth_unix_ro = 'none'
auth_unix_rw = 'none'
EOF

# virt-manager : qemu
cat << EOF | sudo tee -a /etc/libvirt/qemu.conf
user = '${USER}'
group = '${USER}'
EOF

# mysql : create user
mysql --show-warnings --user root --password --execute "\
    DROP USER IF EXISTS user@localhost;\
    CREATE USER IF NOT EXISTS user@localhost IDENTIFIED BY '1234567890';\
    GRANT ALL PRIVILEGES ON *.* TO user@localhost;\
    FLUSH PRIVILEGES;\
    "
# mysql : show details
mysql --show-warnings --user root --password --execute "\
    SELECT user,host,plugin,password_expired FROM mysql.user;\
    "
