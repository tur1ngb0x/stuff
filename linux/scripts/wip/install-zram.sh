#!/usr/bin/env bash

# zram

# ADD KERNEL MODULE
echo 'zram' > /tmp/zram.conf
sudo install -v -D /tmp/zram.conf /etc/modules-load.d/zram.conf
cat /etc/modules-load.d/zram.conf

# ADD UDEV RULE
echo 'ACTION=="add", KERNEL=="zram0", ATTR{initstate}=="0", ATTR{disksize}="4G", ATTR{mem_limit}="4G", ATTR{max_comp_streams}="12", ATTR{comp_algorithm}="zstd", TAG+="systemd"' > /tmp/zram.rules
sudo install -v -D /tmp/zram.rules /etc/udev/rules.d/zram.rules
cat /etc/udev/rules.d/zram.rules

# ADD MOUNT RULE
sudo cp /etc/fstab /etc/fstab.bak
echo '/dev/zram0 none swap defaults,nofail,discard,pri=32767,x-systemd.makefs 0 0' >> /etc/fstab
cat /etc/fstab

/dev/disk/by-uuid/b8702fbf-5120-47b1-ab2e-3c285a26cbb7  /          ext4  defaults 0 1
/dev/disk/by-uuid/68F8-2202                             /boot/efi  vfat  defaults 0 1
/dev/zram0                                              none       swap  defaults,nofail,discard,pri=32767,x-systemd.makefs 0 0

PARTUUID=e7a1397e-38e4-49dc-9c4c-994e7467ac58    /            ext4    defaults                                              0    1
PARTUUID=0fe3ae43-14cb-4cf6-89b0-1e5fe6a69be3    /boot/efi    vfat    defaults                                              0    2
/dev/zram0                                       none         swap    defaults,nofail,discard,pri=32767,x-systemd.makefs    0    0

cat /etc/systemd/zram-generator.conf
[zram0]
zram-size = 4096
compression-algorithm = zstd
