#!/usr/bin/env bash

echo "Removing older downloads ..."
\rm -rf /tmp/adb-linux.zip /tmp/platform-tools

echo "Downloading latest platform tools ..."
\wget -qO /tmp/adb-linux.zip https://dl.google.com/android/repository/platform-tools-latest-linux.zip

echo "Extracting zip ..."
\unzip -q /tmp/adb-linux.zip -d /tmp

echo "Removing older installation ..."
\rm -rf "$HOME/src/platform-tools"

echo "Creating new installation ..."
\mkdir -p "$HOME/src/"

echo "Installing latest platform tools ..."
\mv /tmp/platform-tools ~/src/platform-tools
