#!/usr/bin/env bash

set -e

if [[ "${XDG_SESSION_TYPE}" == 'x11' ]]; then
	i3lock --color=000000 --ignore-empty-password --show-failed-attempts
	xset dpms force off
else
	echo 'not an X11 session'
	exit
fi

# command xset +dpms dpms 0 0 0
# command xset dpms force on
# command xset dpms force off


