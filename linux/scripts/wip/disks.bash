#!/usr/bin/env bash

set -euo pipefail

commands=(
    "blkid"
    "df -h"
    "findmnt"
    "lsblk -f"
    "mount"
    "parted -l"
    "smartctl -x /dev/sda"
    "nvme smart-log /dev/nvme0n1"
)

for cmd in "${commands[@]}"; do
    printf '############################################################\n'
    printf '## %s\n' "$cmd"
    printf '############################################################\n'

    eval sudo "$cmd" 2>&1 || true

    printf '\n'
done
