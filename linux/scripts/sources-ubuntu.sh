#!/usr/bin/env bash

CODENAME="$(lsb_release -cs)"

sudo cp -iv /etc/apt/sources.list /etc/apt/sources.list.bak

cat << EOF | sudo tee /etc/apt/sources.list
deb http://archive.ubuntu.com/ubuntu/ $CODENAME main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ $CODENAME-backports main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ $CODENAME-updates main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu $CODENAME-security main restricted universe multiverse
deb http://archive.canonical.com/ubuntu $CODENAME partner
EOF

sudo apt clean && sudo apt update && sudo apt list --upgradable

