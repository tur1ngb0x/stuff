#!/usr/bin/env bash

declare Creset="\e[0m"
declare Cblue="\e[38;5;21m"
declare Ccyan="\e[38;5;51m"
declare Cgreen="\e[38;5;46m"
declare Cgrey="\e[38;5;245m"
declare Cindigo="\e[38;5;54m"
declare Cmagenta="\e[38;5;201m"
declare Corange="\e[38;5;208m"
declare Cred="\e[38;5;196m"
declare Cviolet="\e[38;5;129m"
declare Cwhite="\e[38;5;231m"
declare Cyellow="\e[38;5;226m"

declare Cbold="\e[1m"
declare Cdim="\e[2m"
declare Citalic="\e[3m"
declare Cunderline="\e[4m"
declare Cblink="\e[5m"
declare Creverse="\e[7m"
declare Chidden="\e[8m"
declare Cstrike="\e[9m"

function ps1_userhost () {
    local user host
	user="$(id -un)"
    host="$(hostname -s)"
    printf "%b%s@%s%b" "${Cgreen}" "${user}" "${host}" "${Creset}"
}

function ps1_dir () {
    local dir; dir="${PWD}"
    printf "%b%s%b" "${Ccyan}" "${dir}" "${Creset}"
}

# function ps1_git () {
#     command -v git &> /dev/null || return
#     git rev-parse --is-inside-git-repository &>/dev/null || return
#     local b; b="$(git rev-parse --abbrev-ref HEAD)"
#     local u; u="$(git ls-files --others --exclude-standard | wc -l)"
#     local w; w="$(git diff --name-only | wc -l)"
#     local s; s="$(git diff --cached --name-only | wc -l)"
#     printf "%b(%s)%b" "${Cwhite}" "${b}" "${Creset}"
#     (( u > 0 )) && printf " %bu%d%b" "${Cred}" "${u}" "${Creset}"
#     (( w > 0 )) && printf " %bw%d%b" "${Cyellow}" "${w}" "${Creset}"
#     (( s > 0 )) && printf " %bs%d%b" "${Cgreen}" "${s}"  "${Creset}"
# }

function ps1_git () {
    command -v git &>/dev/null || return
    git rev-parse --is-inside-git-repository &>/dev/null || return
    local b u w s
	b="$(git rev-parse --abbrev-ref HEAD)"
    mapfile -t u < <(git ls-files --others --exclude-standard)
    mapfile -t w < <(git diff --name-only)
    mapfile -t s < <(git diff --cached --name-only)
    printf "%b(%s)%b" "${Cwhite}" "${b}" "${Creset}"
    ((${#u[@]})) && printf " %bu%d%b" "${Cred}"    "${#u[@]}" "${Creset}"
    ((${#w[@]})) && printf " %bw%d%b" "${Cyellow}" "${#w[@]}" "${Creset}"
    ((${#s[@]})) && printf " %bs%d%b" "${Cgreen}"  "${#s[@]}" "${Creset}"
}

function ps1_venv () {
    local venv; venv="${VIRTUAL_ENV_PROMPT:-$(basename "${VIRTUAL_ENV:-}")}"
    [[ -n ${venv} ]] && printf "%b(%s)%b" "${Cwhite}" "${venv}" "${Creset}"
}

function ps1_sign () {
    local sign; sign="~>"
    printf "%b%s%b" "${Cwhite}" "${sign}" "${Creset}"
}

function set_ps1 () {
    local block_ps1 block_git block_venv
    block_ps1="$(ps1_userhost) $(ps1_dir)"
    block_git=$(ps1_git)
    block_venv=$(ps1_venv)
    [[ -n ${block_git} ]] && block_ps1+=" ${block_git}"
    [[ -n ${block_venv} ]] && block_ps1="${block_venv} ${block_ps1}"
    printf '%s\n%s ' "${block_ps1}" "$(ps1_sign)"
}

# begin script from here
PS1='$(set_ps1)'
PS1="\[\e]0;\u@\h \w\a\]${PS1}"
