#!/usr/bin/env bash

URL="https://github.com/sherlock-project/sherlock.git"
DIR="$HOME/src/sherlock"

/usr/bin/rm -rfv "$DIR" && /usr/bin/mkdir --parents --verbose "$DIR"

/usr/bin/git clone "$URL" "$DIR"

/usr/bin/ls -al "$DIR"
