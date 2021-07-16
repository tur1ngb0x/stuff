#!/usr/bin/env bash

# TEXT BOX
text() {
	local t="| $1 |" && local e=$(echo "$t" | sed 's/./=/g')
	printf "\n\n\n" && echo "$e" && echo "$t" && echo "$e"
}

# GET PATH OF CURRENT DIRECTORY
text "CURRENT DIRECTORY"
cdir="$(pwd)" && echo "$cdir"


# SET CONFIGURATION
apply_bash() {
	rm -rfv "$HOME/.bashrc" /root/.bashrc
	sudo mv -v /etc/bash.bashrc /etc/bash.bashrc.bak
	sudo ln -sv "$cdir/bash/bash_config" /etc/bash.bashrc
}

apply_code() {
	mkdir -pv "$HOME/.config/Code/User"
	if [[ -f "$HOME/.config/Code/User/settings.json" ]]; then
		rm -fv "$HOME/.config/Code/User/settings.json"
	fi
	ln -sv "$cdir/code/settings.json" "$HOME/.config/Code/User/settings.json"
}

apply_git() {
	if [[ -f "$HOME/.gitconfig" ]]; then
		rm -fv "$HOME/.gitconfig"
	fi
	if [[ -f "$HOME/.config/git/config" ]]; then
		rm -fv "$HOME/.config/git/config"
	fi
	"$cdir"/git.sh
}

apply_nano() {
	if [[ -f "/etc/nanorc" ]]; then
		sudo mv "/etc/nanorc" "/etc/nanorc.bak"
	fi
	sudo ln -sv "$cdir/nano/nanorc" "/etc/nanorc"
}

apply_subl() {
	mkdir -pv "$HOME/.config/sublime-text/Packages/User"
	if [[ -f "$HOME/.config/sublime-text/Packages/User/Preferences.sublime-settings" ]]; then
		rm -fv "$HOME/.config/sublime-text/Packages/User/Preferences.sublime-settings"
	fi
	ln -sv "$cdir/subl/Preferences.sublime-settings" "$HOME/.config/sublime-text/Packages/User/Preferences.sublime-settings"
}

# START SCRIPT FROM HERE
text "BASH" && apply_bash
text "GIT" && apply_git
text "VISUAL STUDIO CODE" && apply_code
text "NANO" && apply_nano
text "SUBLIME TEXT" && apply_subl
