#!/usr/bin/env bash

usage() {
    /usr/bin/cat << 'EOF'
description:
  a wrapper for docker to quickly spin up docker containers

usage:
  dkrun.sh <image> [command]

example:
  dkrun.sh image:tag sh -c 'ls /'
EOF
}

/usr/bin/docker >/dev/null 2>&1                     || { builtin echo 'docker cli not installed';    builtin exit 1; }
/usr/bin/id -nG | /usr/bin/grep -qw docker          || { builtin echo 'docker group not available';  builtin exit 1; }
/usr/bin/systemctl is-active --quiet docker.service || { builtin echo 'docker service not running';  builtin exit 1; }
/usr/bin/docker info >/dev/null 2>&1                || { builtin echo 'docker daemon not reachable'; builtin exit 1; }
[[ $# -ge 1 ]]                                      || { usage; builtin exit 1; }

image="${1}"
image_hostname="${1//[:\/.]/_}"
cpus="2"
memory="2G"
user="root"
hostname="docker-$(/usr/bin/date +%s)-${image_hostname}"
workdir="/root"

mounts=(
    "type=bind,src=${HOME}/src,dst=/root/src,readonly"
)

envs=(
    "COLORTERM=${COLORTERM}"
    "EDITOR=${EDITOR}"
    "HOME=/root"
    "LANG=${LANG}"
    "TERM=${TERM}"
    "TZ=${TZ}"
    "VISUAL=${VISUAL}"
)

{ builtin set -x ;} &> /dev/null

/usr/bin/docker --debug --log-level debug \
    container run \
        --rm \
        --interactive \
        --tty \
        --user ${user} \
        --hostname "${hostname}" \
        --cpus "${cpus}" \
        --memory "${memory}" \
        --memory-swap 0 \
        --security-opt no-new-privileges \
        "${envs[@]/#/--env=}" \
        "${mounts[@]/#/--mount=}" \
        --workdir "${workdir}" \
        "${@}"

{ builtin set +x ;} &> /dev/null
