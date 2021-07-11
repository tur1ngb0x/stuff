#!/usr/bin/env bash

# Incompatible packages
incompatible=(tlp tlp-rdw powertop laptop-mode-tools slimbookbattery nvidia-prime system76-power)

if [[ -f /usr/bin/pacman ]]; then
	echo -e "\nInstalling dependencies..."
	sudo pacman -S --noconfirm --needed yay base-devel libusb dbus

	echo -e "\nRemoving incompatible packages..."
	for i in "${incompatible[@]}"; do
		sudo pacman -Rns "$i"
		yay -Rns "$i"
	done

	echo -e "\nInstalling system76-power..."
	yay -S --noconfirm --needed system76-power
elif [[ -f /usr/bin/apt ]]; then
	echo -e "\nInstalling dependencies..."
	sudo apt install -y software-properties-common

	echo -e "\nAdding PPA..."
	sudo apt-add-repository -y ppa:system76-dev/stable

	echo -e "\nPinning PPA package..."
	sudo rm -fv /etc/apt/preferences.d/system76-power.pref
	cat <<-'EOF' | sudo tee /etc/apt/preferences.d/system76-power.pref
	Package: *
	Pin: release o=LP-PPA-system76-dev-stable
	Pin-Priority: -10

	Package: system76-power
	Pin: release o=LP-PPA-system76-dev-stable
	Pin-Priority: 700
	EOF

	echo -e "\nRemoving incompatible packages..."
	for i in "${incompatible[@]}"; do
		sudo apt purge -y "$i"
	done

	echo -e "\nInstalling system76-power..."
	sudo apt update && sudo apt install -y system76-power
elif [[ -f /usr/bin/dnf ]]; then
	echo -e "\nInstalling dependencies..."
	sudo dnf install -y dnf-plugins-core

	echo -e "\nAdding COPR..."
	sudo dnf copr enable -y szydell/system76

	for i in "${incompatible[@]}"; do
		echo -e "\n\n\nRemoving incompatible package: $i"
		sudo dnf remove "$i"
	done

	echo -e "\nInstalling system76-power..."
	sudo dnf install -y system76-power
fi


echo -e "\nAdding user to adm group..."
sudo usermod -a -G adm "$USER"

echo -e "\nEnabling service..."
sudo systemctl enable --now system76-power

echo -e "\nSwitching graphics mode..."
sudo system76-power graphics integrated
