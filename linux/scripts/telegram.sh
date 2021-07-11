#!/usr/bin/env bash

sudo rm -rfv "/opt/Telegram"
sudo rm -fv "/usr/local/bin/telegram-desktop"

sudo rm -rfv "$HOME/.local/share/TelegramDesktop"
sudo rm -fv "$HOME/.local/share/icons/telegram.png"
sudo rm -fv "$HOME/.local/share/applications/appimagekit*-Telegram_Desktop.desktop"

URL="https://telegram.org/dl/desktop/linux"
FILE="/tmp/telegram-desktop.tar.xz"
DIR="/opt"

wget -O "$FILE" "$URL"
sudo tar --verbose --file "$FILE" --extract --xz --directory "$DIR"
sudo ln -sv "$DIR/Telegram/Telegram" "/usr/local/bin/telegram-desktop"

printf "\n\n\nType telegram-desktop in the terminal to generate desktop entry and launch application\n\n"

