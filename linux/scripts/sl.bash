#!/usr/bin/env bash

if [[ "${XDG_SESSION_TYPE}" == 'x11' ]]; then
	i3lock --color=000000 --ignore-empty-password --show-failed-attempts
	xset dpms force off
else
	echo 'not an X11 session'
fi

