#!/usr/bin/env bash

{ set -x; } &>/dev/null

sudo pacman --verbose --sync --needed --noconfirm git base-devel

sudo rm --verbose --force --recursive /tmp/yay-bin

git clone --verbose --ipv4 --depth=1 https://aur.archlinux.org/yay-bin.git /tmp/yay-bin

pushd /tmp/yay-bin || exit

builtin printf '%s\n%s\n' 'OPTIONS=(docs emptydirs purge strip zipman !debug !libtool !lto !staticlibs)' "PKGEXT='.pkg.tar'" >| /tmp/makepkg.conf

install --verbose -D /tmp/makepkg.conf "${HOME}"/.config/pacman/makepkg.conf

makepkg --cleanbuild --clean --syncdeps --install --force --rmdeps --needed --noconfirm

file /usr/bin/yay

# sudo rm --verbose --force --recursive "${HOME}"/.config/pacman

# /usr/bin/pikaur --color=always --verbose --noconfirm --sync --noedit --nodiff brave-bin ente-auth-bin bitwarden-bin

# sudo pacman --remove --nosave --recursive pikaur

{ set +x; } &>/dev/null
