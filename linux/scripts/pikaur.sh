#!/usr/bin/env bash

set -euxo pipefail

sudo pacman --verbose --sync --needed --noconfirm git base-devel

sudo rm --verbose --force --recursive /tmp/pikaur

git clone --verbose --ipv4 --depth=1 https://aur.archlinux.org/pikaur.git /tmp/pikaur

pushd /tmp/pikaur

builtin printf '%s\n' 'OPTIONS=(strip docs !libtool !staticlibs emptydirs zipman purge !debug !lto)' >| /tmp/makepkg.conf

install --verbose -D /tmp/makepkg.conf "${HOME}"/.config/pacman/makepkg.conf

makepkg --cleanbuild --clean --syncdeps --install --force --rmdeps --needed --noconfirm

sudo rm --verbose --force --recursive "${HOME}"/.config/pacman

# /usr/bin/pikaur --color=always --verbose --noconfirm --sync --noedit --nodiff brave-bin ente-auth-bin bitwarden-bin

# sudo pacman --remove --nosave --recursive pikaur