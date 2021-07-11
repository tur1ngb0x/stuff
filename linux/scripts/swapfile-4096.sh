#!/usr/bin/env bash

echo "Creating /swapfile..."
sudo dd if=/dev/zero of=/swapfile bs=1M count=4096 status=progress

echo "Setting permissions..."
sudo chmod --verbose 600 /swapfile

echo "Formatting to swap..."
sudo mkswap /swapfile

echo "Activating swap"
sudo swapon --verbose /swapfile

echo "Backing up /etc/fstab..."
sudo cp --verbose /etc/fstab /etc/fstab.bak

echo "Adding swap entry to /etc/fstab"
sudo bash -c "echo '/swapfile none swap defaults 0 0' >> /etc/fstab"

echo "Backing up /etc/sysctl.conf..."
sudo cp --verbose "/etc/sysctl.conf" "/etc/sysctl.conf.bak"

echo "Changing swappiness value..."
sudo bash -c "echo 'vm.swappiness=10' >> /etc/sysctl.conf"

echo "Reloading sysctl.conf..."
sudo sysctl -p

printf "\n\n/swapfile created and activated\n\n"
command free -m
sudo cat /etc/fstab | tail -n1
