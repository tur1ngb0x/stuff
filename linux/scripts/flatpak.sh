#!/usr/bin/env bash

sudo apt install -y flatpak

# Default Flatpak Stable Remote
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && flatpak remotes

# Flatpak Apps
flatpak --user install flathub com.github.tchx84.Flatseal -y

flatpak --user install flathub io.github.kotatogram -y

flatpak --user install flathub net.cozic.joplin_desktop -y

flatpak --user install flathub org.kde.kolourpaint -y

flatpak --user install flathub org.videolan.VLC -y

flatpak --user install flathub org.gnome.Boxes -y

flatpak --user install flathub org.libreoffice.LibreOffice -y
