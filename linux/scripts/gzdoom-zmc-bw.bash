#!/usr/bin/env bash

# #######################################################################################
# GZDOOM
# #######################################################################################

mkdir -pv ~/.config/gzdoom/zmc-bw-7.2
pushd ~/.config/gzdoom/zmc-bw-7.2
gzdoom -iwad ~/.config/gzdoom/doom2.wad -file ~/.config/gzdoom/zmc-bw-7.2/zmc-bw-7.2.pk3 -nostartup
popd

# $ yay -Sii gzdoom-bin
# Repository                    : aur
# Name                          : gzdoom-bin
# Version                       : 4.14.2-6
# Description                   : Feature centric port for all Doom engine games
# URL                           : https://github.com/ZDoom/gzdoom
# Licenses                      : BSD  GPL3  LGPL3
# Groups                        : None
# Provides                      : None
# Depends On                    : gtk3  hicolor-icon-theme  libgl  libvpx>=1.14  libwebp  openal  sdl2  libvpx
# Optional Deps                 : None
# Make Deps                     : unzip
# Check Deps                    : None
# Conflicts With                : gzdoom  gzdoom-git
# Replaces                      : None
# AUR URL                       : https://aur.archlinux.org/packages/gzdoom-bin
# First Submitted               : Sat 23 Mar 2024 09:18:11 AM IST
# Keywords                      : None
# Last Modified                 : Wed 05 Nov 2025 01:46:41 PM IST
# Maintainer                    : gameslayer
# Popularity                    : 0.508470
# Votes                         : 6
# Out-of-date                   : No
# ID                            : 1875039
# Package Base ID               : 204031
# Package Base                  : gzdoom-bin
# Snapshot URL                  : https://aur.archlinux.org/cgit/aur.git/snapshot/gzdoom-bin.tar.gz

# $ /usr/bin/ls -al /home/user/.config/gzdoom/
# total 306428
# drwx------  3 user user      4096 Jun  4 15:13 .
# drwxr-xr-x 49 user user      4096 Jun  6 18:48 ..
# -rw-r--r--  1 user user  14943400 Aug 25  1994 doom2.wad
# -rw-r--r--  1 user user     18834 Jun  6 14:28 gzdoom.ini
# drwxr-xr-x  3 user user      4096 Jun  4 15:13 savegames
# -rw-r--r--  1 user user 298795222 Nov 16  2025 ZMC-BWV7.2.pk3

# $ /usr/bin/ls -al /home/user/.local/share/gzdoom/
# ls: cannot access '/home/user/.local/share/gzdoom/': No such file or directory
