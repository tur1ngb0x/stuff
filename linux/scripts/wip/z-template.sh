#!/usr/bin/env bash

# posix locale
LC_ALL=C

# strict mode
set -euo pipefail

# show usage info
usage() {
    local reset=$'\033[0m'       # reset
    local bold=$'\033[1m'        # bold
    local italic=$'\033[3m'      # italic
    local underline=$'\033[4m'   # underline
    local reverse=$'\033[7m'     # reverse
    local dim=$'\033[2m'         # dim
    local violet=$'\033[35m'     # violet
    local indigo=$'\033[34m'     # indigo
    local blue=$'\033[94m'       # blue
    local green=$'\033[32m'      # green
    local yellow=$'\033[33m'     # yellow
    local orange=$'\033[91m'     # orange
    local red=$'\033[31m'        # red

    cat << EOF
${reverse}${bold} DESCRIPTION ${reset}
Add script description here.
Add relevant project links

${reverse}${bold} SYNTAX ${reset}
$0 <option> [option]
${0##*/} <option> [option]

${reverse}${bold} OPTIONS ${reset}
opt1 -
opt2 -
opt3 -
optN -
EOF
}

# show command and run it
# show ls
# 1970-01-01 20:30:59 | $ ls 
show() { printf '%s # %s | $ %s %s\n' "$(tput rev)" "$(date '+%Y-%m-%d %H:%M:%S')" "$*" "$(tput sgr0)"; eval "${@:?}"; }

# main function
main() {
    fn1
    fn2
    fn3
    fnN
}

# if command not found, exit
if ! command -v cmd &>/dev/null; then usage; exit; fi

# if command found, exit
if command -v cmd &>/dev/null; then usage; exit; fi

# if no args, exit
if [ $# -eq 0 ]; then usage; exit; fi

# if args, exit immediately
if [ $# -ne 0 ]; then usage; exit; fi

# declarative array
declare array=('1' '2' '3' '4' '5')
# print 1st element
echo "${array[0]}"
# print last element
echo "${array[-1]}"
# print each element
for i in "${array[@]}"; do echo "${i}"; done

# associative array
declare -A array=([1]='A' [2]='B' [3]='C' [4]='D' [5]='E')
# print value for key 1
echo "${array[1]}"
# print value for key 5
echo "${array[5]}"
# loop and print each key and value
for k in "${!array[@]}"; do echo "$k -> ${array[$k]}"; done

# call main
main "${@}"

# script completion template
# $ cat ~/.local/share/bash-completion/completions/script
_script_sh() {
    local cur
    cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "arg1 arg2 arg3 argN" -- "${cur}") )
}

complete -F _script_sh script.sh
