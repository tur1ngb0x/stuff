#!/usr/bin/env bash

URL="https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz"
FILE="/tmp/shell-check.tar.xz"
DIR="$HOME/src/shellcheck-stable"


/usr/bin/wget -O "$FILE" "$URL" && /usr/bin/rm -rfv "$DIR" 

/usr/bin/mkdir --parents --verbose "$DIR" && /usr/bin/tar --verbose --file "$FILE" --extract --xz --strip-components 1 --directory "$DIR" && /usr/bin/ls -al --color=auto "$DIR"
