#!/usr/bin/env bash

echo "Showing hidden startup applications..."
sudo sed -i "s/NoDisplay=true/NoDisplay=false/g" /etc/xdg/autostart/*.desktop && echo "Done"
