#!/usr/bin/env bash

# print file:line:command before each command
trap 'printf "%s:%s | \e[1m%s\e[0m" "$(readlink -f "${BASH_SOURCE}")" "${LINENO}" "${BASH_COMMAND}"; read -r -p ""' DEBUG

# your commands go here
echo 'this is line 1'
echo 'this is line 2'
echo 'this is line 3'
