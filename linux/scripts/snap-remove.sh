#!/usr/bin/env bash

# Remove installed snaps
sudo snap remove --purge snap-store
sudo snap remove --purge gtk-common-themes
sudo snap remove --purge gnome-3-34-1804
sudo snap remove --purge core18
sudo snap remove --purge core20
sudo snap remove --purge snapd

# Remove snap package
sudo apt purge -y snapd
sudo apt purge -y gnome-software-plugin-snap

# Remove snap directories
sudo rm -rfv "$HOME/snapd"
sudo rm -rfv /snap
sudo rm -rfv /var/snap
sudo rm -rfv /var/lib/snapd

# Hold snap package
sudo apt-mark hold snapd

# Disable snap package
sudo rm -fv /etc/apt/preferences.d/disable-snapd.pref
cat << EOF | sudo tee /etc/apt/preferences.d/disable-snapd.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
