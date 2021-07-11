#!/usr/bin/env bash

echo "Backing up default blacklist..."
sudo cp -iv /etc/modprobe.d/blacklist.conf /etc/modprobe.d/blacklist.conf.bak

echo "Blacklisting kernel modules..."
cat << EOF | sudo tee -a /etc/modprobe.d/blacklist.conf
# ################ Begin User Added Modules ################
# Acer
blacklist acer_wireless
blacklist acer_wmi

# Bluetooth
blacklist bluetooth
blacklist bnep
blacklist btbcm
blacklist btintel
blacklist btrtl
blacklist btusb
blacklist rfcomm

# Card Reader
blacklist rtsx_pci
blacklist rtsx_pci_sdmmc

# Camera
blacklist uvcvideo

# Ethernet
blacklist r8169

# Intel
blacklist intel_wmi_thunderbolt

# Nvidia
blacklist i2c_nvidia_gpu
blacklist nouveau
blacklist nvidia
blacklist nvidia-drm
blacklist nvidia-modeset
# ################ End User Added Modules ################
EOF

echo "Removing bluetooth service..."
sudo systemctl stop bluetooth
sudo systemctl disable bluetooth

echo "Updating initramfs..."
sudo update-initramfs -k all -u -v

echo "Rebooting machine..."
printf "\n\nReboot for changes to take effect\n\n"
