#!/usr/bin/env bash

builtin set -euo pipefail

commands=(
    'cmd1'
    'cmd2'
    'cmd3'
    'cmdN'
)

for cmd in "${commands[@]}"; do
    builtin printf '############################################################\n'
    builtin printf '## %s\n' "${cmd}"
    builtin printf '############################################################\n'

    builtin eval /usr/bin/sudo "${cmd}" 2>&1 || builtin true

    builtin printf '\n'
done
