#!/usr/bin/env bash

set -x

pkill -9 xfwm4

(nohup xfwm4 &) &>/dev/null

pkill -9 xfdesktop;

(nohup xfdesktop &) &>/dev/null

pkill -9 xfce4-panel

(nohup xfce4-panel &) &>/dev/null
