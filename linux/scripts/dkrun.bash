#!/usr/bin/env bash

usage() {
    /usr/bin/cat << 'EOF'
description:
  quickly spin up docker containers using images and commands

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

hostname="docker-$(/usr/bin/date +%s)"

{ builtin set -x ;} &> /dev/null

/usr/bin/docker --debug --log-level debug \
    container run \
        --rm \
        --interactive \
        --tty \
        --cpus 2 \
        --memory 2G \
        --memory-swap 0 \
        --user root \
        --hostname "${hostname}" \
        --volume "${HOME}/src/:/root/src:ro" \
        --workdir /root \
        "${@}"

{ builtin set +x ;} &> /dev/null
