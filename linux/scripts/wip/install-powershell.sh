#!/usr/bin/env bash

# ms repo

curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/24.04/prod noble main" | sudo tee /etc/apt/sources.list.d/microsoft.list

sudo apt-get update && sudo apt-get install powershell

$ /usr/bin/wget -4 --spider -r -np -nd --delete-after https://packages.microsoft.com/ubuntu/24.04/prod/pool/main/p/powershell/ 2>&1 | grep '^--' | awk '{print $3}'
