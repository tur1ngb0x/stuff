#!/usr/bin/env bash

echo -e "\n\n\nInstalling QT5 Packages..."
if [[ -f /usr/bin/apt ]]; then
	sudo apt install -y libcanberra-gtk3-module libcanberra-gtk-module
	sudo apt install -y appmenu-gtk3-module appmenu-gtk2-module
	sudo apt install -y qt5ct
	sudo apt install -y qt5-style-plugins
	sudo apt install -y qt5-style-plugin-gtk2
	sudo apt install -y breeze
elif [[ -f /usr/bin/dnf ]]; then
	sudo dnf install -y qt5ct
elif [[ -f /usr/bin/pacman ]]; then
	sudo pacman -S --needed --noconfirm qt5ct
	yay -S --needed --noconfirm qt5-stylepluins
fi

if [[ ! -f "$HOME/.profile" ]]; then
	echo -e "\n\n\nCreating $HOME/.profile"
	touch "$HOME/.profile"
fi

echo -e "\n\n\nBacking up $HOME/.profile..."
cp -v "$HOME/.profile" "$HOME/.profile.bak"

echo -e "\n\n\nExporting QT variables to $HOME/.profile..."
cat << EOF | tee -a "$HOME/.profile"
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export QT_SCALE_FACTOR=1
export QT_SCREEN_SCALE_FACTORS=1
export QT_FONT_DPI=96
export PLASMA_USE_QT_SCALING=1
export QT_QPA_PLATFORMTHEME=qt5ct # or gtk2
export QT_PLATFORMTHEME=qt5ct
export QT_PLATFORM_PLUGIN=qt5ct
EOF

echo -e "\n\n\nCreating $HOME/.config/qt5ct..."
mkdir -pv "$HOME/.config/qt5ct"

echo -e "\n\n\nRemoving existing $HOME/.config/qt5ct/qt5ct.conf"
rm -fv "$HOME/.config/qt5ct/qt5ct.conf"

echo -e "\n\n\nAdding default settings to $HOME/.config/qt5ct/qt5ct.conf..."
cat << EOF | tee "$HOME/.config/qt5ct/qt5ct.conf"
[Appearance]
custom_palette=false
standard_dialogs=gtk2
style=gtk2
EOF

echo -e "\n\n\nCreating $HOME/.config/fontconfig..."
mkdir -pv "$HOME/.config/fontconfig"

echo -e "\n\n\nRemoving existing $HOME/.config/fontconfig/fonts.conf"
rm -fv "$HOME/.config/fontconfig/fonts.conf"

echo -e "\n\n\nAdding default settings to $HOME/.config/fontconfig/fonts.conf..."
cat << EOF | tee "$HOME/.config/fontconfig/fonts.conf"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <match target="font">
        <edit name="antialias" mode="assign">
            <bool>true</bool>
        </edit>
        <edit name="hinting" mode="assign">
            <bool>true</bool>
        </edit>
        <edit name="hintstyle" mode="assign">
            <const>hintslight</const>
        </edit>
        <edit name="rgba" mode="assign">
            <const>rgb</const>
        </edit>
        <edit name="autohint" mode="assign">
            <bool>false</bool>
        </edit>
        <edit name="lcdfilter" mode="assign">
            <const>lcddefault</const>
        </edit>
        <edit name="dpi" mode="assign">
            <double>96</double>
        </edit>
    </match>
</fontconfig>
EOF

printf "\n\nRestart for changes to take effect\n\n"
