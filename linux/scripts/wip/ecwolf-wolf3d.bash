#!/usr/bin/env bash

# #######################################################################################
# ECWOLF
# #######################################################################################

mkdir -pv ~/.local/share/ecwolf/wolf3d-full
pushd ~/.local/share/ecwolf/wolf3d-full
ecwolf --data wl6
popd

# $ yay -Sii ecwolf
# Repository                    : aur
# Name                          : ecwolf
# Version                       : 1.4.2-1
# Description                   : Advanced source port for Wolfenstein 3D engine games
# URL                           : https://maniacsvault.net/ecwolf/
# Licenses                      : GPL-2.0-or-later
# Groups                        : None
# Provides                      : None
# Depends On                    : gtk3  libjpeg-turbo  sdl2  sdl2_mixer  sdl2_net
# Optional Deps                 : None
# Make Deps                     : cmake
# Check Deps                    : None
# Conflicts With                : None
# Replaces                      : None
# AUR URL                       : https://aur.archlinux.org/packages/ecwolf
# First Submitted               : Tue 26 Jan 2021 09:27:03 AM IST
# Keywords                      : ecwolf  fps  game  retro  shooter  wolf3d  wolf4sdl  wolfenstein3d
# Last Modified                 : Sun 19 Oct 2025 10:04:35 PM IST
# Maintainer                    : FredBezies
# Popularity                    : 0.000000
# Votes                         : 3
# Out-of-date                   : No
# ID                            : 1858865
# Package Base ID               : 162566
# Package Base                  : ecwolf
# Snapshot URL                  : https://aur.archlinux.org/cgit/aur.git/snapshot/ecwolf.tar.gz

# $ /usr/bin/ls -al /home/user/.config/ecwolf/
# total 12
# drwx------  2 user user 4096 Jun  2 10:35 .
# drwxr-xr-x 49 user user 4096 Jun  6 18:48 ..
# -rw-r--r--  1 user user 3575 Jun  5 11:38 ecwolf.cfg

# $ /usr/bin/ls -al /home/user/.local/share/ecwolf/
# total 11368
# drwxr-xr-x  5 user user    4096 Jun  5 11:27 .
# drwxr-xr-x 47 user user    4096 Jun  6 18:52 ..
# -rw-r--r--  1 user user    1156 Apr 30  2021 AUDIOHED.WL6
# -rw-r--r--  1 user user  320209 Apr 30  2021 AUDIOT.WL6
# drwxr-xr-x  2 user user    4096 Jun  2 19:00 bak
# -rw-r--r--  1 user user     522 Apr 30  2021 CONFIG.WL6
# -rw-r--r--  1 user user 9295882 Jun  3 19:06 ECWolf_hdpack.pk3
# lrwxrwxrwx  1 user user      28 Jun  2 10:35 ecwolf.pk3 -> /usr/share/ecwolf/ecwolf.pk3
# -rw-r--r--  1 user user  150652 Apr 30  2021 GAMEMAPS.WL6
# -rw-r--r--  1 user user     402 Apr 30  2021 MAPHEAD.WL6
# drwx------  2 user user    4096 Jun  3 18:52 savegames
# drwx------  2 user user    4096 Jun  2 10:32 screenshots
# -rw-r--r--  1 user user    1024 Apr 30  2021 VGADICT.WL6
# -rw-r--r--  1 user user  276096 Apr 30  2021 VGAGRAPH.WL6
# -rw-r--r--  1 user user     450 Apr 30  2021 VGAHEAD.WL6
# -rw-r--r--  1 user user 1545400 Apr 30  2021 VSWAP.WL6
