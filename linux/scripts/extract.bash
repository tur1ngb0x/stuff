#!/usr/bin/env bash

usage() {
    /usr/bin/cat << 'EOF'
description:
  a wrapper for atool to quickly extract archives

usage:
  extract.bash <archive>

example:
  extract.bash somefile.tar.gz
EOF
}

if [[ $# -lt 1 ]]; then
    usage
    builtin exit 1
fi

/usr/bin/atool --list "${1:?}"

builtin read -r -p "Proceed? (N/yes): " ans
[[ "${ans}" == yes ]] || builtin exit 1

/usr/bin/atool --explain --extract --force --subdir "${1:?}"
