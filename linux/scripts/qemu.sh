#!/usr/bin/env bash

set -euo pipefail

# If ISO directory does not exist, exit
#ISO_DIR="${HOME}/src/iso"

BASE="/mnt/data/qemu"
ISO_DIR="/mnt/data/iso"
if [[ ! -d "${ISO_DIR}" ]]; then
    echo "ISO directory does not exist: ${ISO_DIR}"
    exit 1
fi

# If no ISO argument provided, use fzf to select one
if [[ $# -eq 0 ]]; then
    ISO_INPUT="$( find "${ISO_DIR}" -type f -iname '*.iso' 2>/dev/null | sort | fzf --prompt='Select ISO: ')"
    if [[ -z "${ISO_INPUT}" ]]; then
        echo "No ISO selected"
        exit
    fi
else
    ISO_INPUT="${1:?ISO path required}"
fi

ISO_PATH="$(readlink -f -- "${ISO_INPUT}")"
ISO_NAME="$(basename -- "${ISO_PATH}" .iso)"
DISK="${ISO_NAME}.qcow2"
VM_DIR="${BASE}/${ISO_NAME}"

mkdir -p -- "${VM_DIR}"
pushd -- "${VM_DIR}" || exit

# if disk is missing, create it
if [[ ! -f "${DISK}" ]]; then
    /usr/bin/qemu-img create -f qcow2 -o lazy_refcounts=on "${DISK}" 30G
fi

# check disk
/usr/bin/qemu-img check "${DISK}"
/usr/bin/qemu-img measure "${DISK}"
/usr/bin/qemu-img info "${DISK}"

if [[ -f "${DISK}" ]]; then
    /usr/bin/qemu-system-x86_64 \
        -name "${ISO_NAME}",process="${ISO_NAME}" \
        -pidfile "${VM_DIR}/${ISO_NAME}.pid" \
        -machine q35,accel=kvm,smm=off,vmport=off \
        -global kvm-pit.lost_tick_policy=discard \
        -cpu host \
        -smp sockets=1,cores=2,threads=2 \
        -m 4G \
        -device virtio-balloon \
        -rtc base=utc,clock=host \
        -vga none \
        -device virtio-vga-gl,edid=on,blob=true,xres=1920,yres=1080 \
        -display sdl,gl=on \
        -device virtio-rng-pci,rng=rng0 \
        -object rng-random,id=rng0,filename=/dev/urandom \
        -device usb-ehci,id=input \
        -device usb-kbd,bus=input.0 \
        -device usb-tablet,bus=input.0 \
        -device virtio-net-pci,netdev=nic \
        -k en-us \
        -netdev user,id=nic \
        -drive media=cdrom,index=0,file="${ISO_PATH}" \
        -device virtio-blk-pci,drive=SystemDisk \
        -drive id=SystemDisk,if=none,format=qcow2,file="${DISK}"
fi

popd
