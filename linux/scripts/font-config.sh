#!/usr/bin/env bash

if [[ -f /usr/bin/apt ]]; then
	echo "Font config is not needed"
elif [[ -f /usr/bin/dnf ]]; then
	sudo dnf copr enable dawid/better_fonts -y
	sudo dnf install ubuntu-fonts fontconfig-font-replacements fontconfig-enhanced-defaults -y
elif [[ -f /usr/bin/pacman ]]; then
	echo "Removing font.conf..."
	sudo rm -fv "/etc/fonts/local.conf" && echo "Done"

	echo "Creating font.conf..."
	cat <<-'EOF' | sudo tee "/etc/fonts/local.conf"
	<?xml version="1.0"?>
	<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
	<fontconfig>
		<match target="font">
			<edit name="autohint" mode="assign">
				<bool>false</bool>
			</edit>
			<edit name="hinting" mode="assign">
				<bool>true</bool>
			</edit>
			<edit name="antialias" mode="assign">
				<bool>true</bool>
			</edit>
			<edit mode="assign" name="hintstyle">
				<const>hintslight</const>
			</edit>
			<edit mode="assign" name="rgba">
				<const>rgb</const>
			</edit>
			<edit mode="assign" name="lcdfilter">
				<const>lcddefault</const>
			</edit>
		</match>
	</fontconfig>
	EOF
	echo "Done"

	echo "Removing Xresources..."
	sudo rm -fv "$HOME/.Xresources" && echo "Done"

	echo "Creating Xresources..."
	cat <<-'EOF' | tee "$HOME/.Xresources"
	Xft.dpi: 96
	Xft.antialias: 1
	Xft.hinting: 1
	Xft.rgba: rgb
	Xft.autohint: 0
	Xft.hintstyle: hintslight
	Xft.lcdfilter: lcddefault
	EOF
	echo "Done"

	echo "Merging Xresources..."
	xrdb -merge "$HOME/.Xresources" && echo "Done"

	echo "Creating symlinks to font config..."
	sudo ln -sv  "/etc/fonts/conf.avail/10-sub-pixel-rgb.conf" "/etc/fonts/conf.d/"  && echo "Done"
	sudo ln -sv  "/etc/fonts/conf.avail/11-lcdfilter-default.conf" "/etc/fonts/conf.d/"  && echo "Done"

	echo "Backing up freetype config..."
	sudo cp -iv "/etc/profile.d/freetype2.sh" "/etc/profile.d/freetype2.sh.bak" && echo "Done"

	echo "Creating freetype config..."
	cat <<-'EOF' | sudo tee -a "/etc/profile.d/freetype2.sh"
	export FREETYPE_PROPERTIES="truetype:interpreter-version=40"
	EOF

	echo "Installing Ubuntu fonts..."
	sudo pacman -S --needed --noconfirm ttf-ubuntu-font-family
fi

printf "\n\nReboot for changes to take effect\n\n"

