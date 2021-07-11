#!/usr/bin/env bash

URL="https://github.com/subhra74/xdm/releases/download/7.2.11/xdm-setup-7.2.11.tar.xz"

FILE="xdm-setup.tar.gz"

DIR="/tmp"

wget -O "$DIR/$FILE" "$URL"

sudo rm -rfv /opt/xdman && sudo rm -fv /usr/bin/xdman && sudo rm -fv /install-script.sh

sudo tar --verbose --file "$DIR/$FILE" --extract --directory "$DIR"

sudo "$DIR/install.sh"
