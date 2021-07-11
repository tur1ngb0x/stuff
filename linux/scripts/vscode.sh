#!/usr/bin/env bash

if [[ -f /usr/bin/pacman ]]
then
	sudo pacman -S --noconfirm --needed code
	#yay -S --noconfirm --needed visual-studio-code-bin
elif [[ -f /usr/bin/apt ]]
then
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
	sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
	sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
	sudo apt install -y apt-transport-https
	
	sudo rm -fv /etc/apt/preferences.d/vscode.pref && rm -fv packages.microsoft.gpg
	
	cat <<-'EOF' | sudo tee /etc/apt/preferences.d/vscode.pref
	Package: code
	Pin: origin "packages.microsoft.com"
	Pin-Priority: 9999
	EOF
	
	sudo apt update && sudo apt install -y code
elif [[ -f /usr/bin/dnf ]]
then
	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc -y
	sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
	sudo dnf install -y code
fi

