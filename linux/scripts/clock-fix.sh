#!/usr/bin/env bash

echo "Changing timezone..."
sudo timedatectl set-timezone Asia/Kolkata && echo "Done"

echo "Setting hardware clock to local time..."
sudo timedatectl set-local-rtc 1 --adjust-system-clock && echo "Done"
