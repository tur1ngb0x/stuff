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


# debug 1
# debug 0
debug() {
    local arg="${1}"
    [[ "${arg}" == 1 ]] && { set -x; } &>/dev/null && return 0
    [[ "${arg}" == 0 ]] && { set +x; } &>/dev/null && return 0
    return 2
}

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


_detect_id() {
    ( . /etc/os-release; printf '%s\n' "${ID,,}")
}; _detect_id

_detect_pm() {
    for pm in apt-get dnf pacman; do
        if [[ -f "/usr/bin/${pm}" ]]; then
            printf '%s\n' "${pm}"
        fi
    done
}; _detect_pm

_detect_distro(){
    wget -q -4 -O /tmp/distro.sh https://www.observium.org/files/distro \
        && chmod +x /tmp/distro.sh \
        && sh /tmp/distro.sh | awk -F'|' '
            {
                for (i=1; i<=7; i++) if ($i=="") $i="N/A"

                for (i=1; i<=7; i++) {
                    gsub(/\\/,"\\\\",$i)
                    gsub(/"/,"\\\"",$i)
                }

                print "operating_system="      $1
                print "kernel_version="       $2
                print "cpu_architecture="     $3
                print "distribution_name="    $4
                print "distribution_version=" $5
                print "virtualization_type="  $6
                print "container_type="       $7
            }'
}; _detect_distro
