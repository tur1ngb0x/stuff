#!/usr/bin/env bash

# directories
mkdir -pv "${HOME}"/Apps
mkdir -pv "${HOME}"/.local/bin
mkdir -pv "${HOME}"/.local/share/applications

function gui_toolbox {
	#tar --file /tmp/toolbox.tar.gz -vvv --extract --gzip --strip-components 1 --directory /tmp/toolbox
	mkdir -pv "${HOME}"/Apps/jetbrains-toolbox
	wget -4O /tmp/toolbox.tar.gz 'https://data.services.jetbrains.com/products/download?platform=linux&code=TBA'
	tar --file /tmp/toolbox.tar.gz -vvv --extract --gzip --strip-components 1 --directory "${HOME}"/Apps/jetbrains-toolbox
	(nohup ~/Apps/jetbrains-toolbox/bin/jetbrains-toolbox &) &> /tmp/jetbrains-toolbox.txt
}

# begin script from here
gui_toolbox
