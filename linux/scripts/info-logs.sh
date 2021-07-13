#!/usr/bin/env bash

separator() { printf '\n\n\n\n'; }

(\
	date
	separator

	echo 'sudo systemctl --failed'
	sudo systemctl --failed
	separator
	
	echo 'sudo journalctl --list-boots'
	sudo journalctl --list-boots
	separator

	echo 'sudo journalctl --catalog --boot=-2 --priority=3'
	sudo journalctl --catalog --boot=-2 --priority=3
	separator

	echo 'sudo journalctl --catalog --boot=-1 --priority=3'
	sudo journalctl --catalog --boot=-1 --priority=3
	separator

	echo 'sudo journalctl --catalog --boot=0 --priority=3'
	sudo journalctl --catalog --boot=0 --priority=3
	separator

	echo "find $HOME -user root"
	find "$HOME" -user root
	separator

	if [[ -f /usr/bin/pacman ]]; then
		echo 'sudo find / -iname "*pacnew*"'
		sudo find / -iname "*pacnew*" 2>/dev/null
		separator

		echo 'sudo find / -iname "*pacsave*"'
		sudo find / -iname "*pacsave*" 2>/dev/null
		separator
	fi
) > ~/system-logs-"$(date +"%Y%m%d-%H%M%S")".txt && echo "System logs saved in home directory"
