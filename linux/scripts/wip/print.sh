#!/usr/bin/env bash

LC_ALL=C
builtin set -euo pipefail

if [[ "${#}" -ne 1 ]]; then
	echo 'syntax:'
	echo 'print.sh /path/of/the/file'
	exit
elif command -v batcat &>/dev/null; then
	command batcat --set-terminal-title --style full --paging never "${@}"
elif command -v bat &>/dev/null; then
	command bat --set-terminal-title --style full --paging never "${@}"
elif command -v cat &>/dev/null; then
	command cat --number "${@}"
else
	echo 'bat/cat not found'
	exit
fi
