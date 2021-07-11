#!/usr/bin/env bash



# FUNCTIONS
header() {
	title="| $1 |" && edge=$(echo "$title" | sed 's/./—/g')
	printf "\n\n" && echo "$edge" && echo "$title" && echo "$edge"
}



# BEGIN SCRIPT FROM HERE
header "OS Release"
grep -v '^#' /etc/os-release | awk NF



header "Linux Standard Base"
lsb_release --id --release --description --codename



header "Linux Kernel"
uname --all



header "Bootloader"
if [[ -f /etc/default/grub ]]; then
	grep -v '^#' /etc/default/grub | awk NF
fi



header "File System Table"
grep -v '^#' /etc/fstab | awk NF | tr -s ' '
echo ""
command lsblk -f | grep -v '^loop'



header "Package Managers"
if [[ -f /usr/bin/apt ]]; then
	echo "apt $(apt --version | awk '{ print $2 }') ($(dpkg -l | grep -c '^ii') packages)"
	grep -v '^#' /etc/apt/sources.list | awk NF
	grep -v '^#' /etc/apt/sources.list.d/*.list | awk NF | cut -d: -f2-
fi

if [[ -f /usr/bin/dnf ]]; then
	echo ""
	echo "dnf: "
fi

if [[ -f /usr/bin/flatpak ]]; then
	echo ""
	echo "flatpak $(flatpak --version | awk '{ print $2 }') ($(flatpak list --all | wc -l) packages)"
	flatpak remotes | head -n1
fi

if [[ -f /usr/bin/pacman ]]; then
	echo ""
	grep -v '^#' /etc/pacman/mirrorlist | awk NF
	echo "pacman: "
fi

if [[ -f /usr/bin/paru ]]; then
	echo ""
	echo "paru: "
fi

if [[ -f /usr/bin/snap ]]; then
	echo ""
	echo "snap $(snap version | head -n1 | awk '{ print $2 }') ($(snap list --all | wc -l) packages)"
fi

if [[ -f /usr/bin/yay ]]; then
	echo "yay: "
fi



header "Desktop"
if [[ -f /usr/bin/cinnamon ]]; then
	cinnamon --version | head -n1
elif [[ -f /usr/bin/gnome-shell ]]; then
	gnome-shell --version | head -n1
elif [[ -f /usr/bin/mate-session ]]; then
	mate-session --version | head -n1
elif [[ -f /usr/bin/plasmashell ]]; then
	plasmashell --version | head -n1
elif [[ -f /usr/bin/xfce4-session ]]; then
	xfce4-session --version | head -n1
fi

echo "$XDG_SESSION_TYPE display protocol"
echo "Installed Themes: $(command ls /usr/share/themes | wc -l)"
echo "Installed Icons: $(command ls /usr/share/icons | wc -l)"
echo "Installed Fonts: $(fc-list | wc -l)"


