#!/usr/bin/env bash

command -v docker >/dev/null 2>&1 ||            { echo 'docker cli not installed'; exit 1; }
id -nG | grep -qw docker ||                     { echo 'docker group not available'; exit 1; }
systemctl is-active --quiet docker.service ||   { echo 'docker service not running'; exit 1; }
docker info >/dev/null 2>&1 ||                  { echo 'docker daemon not reachable'; exit 1; }

usage() {
    cat << 'EOF'
usage:
  dkrun.sh <image> [command]

example:
  dkrun.sh image:tag sh -c 'ls /'
EOF
}

if [[ $# -lt 1 ]]; then
    usage
    exit 2
fi

{ set -x ;} &> /dev/null

docker --debug --log-level debug \
    container run \
        --rm \
        --interactive \
        --tty \
        --cpus 2 \
        --memory 2G \
        --memory-swap 0 \
        --user root \
        --hostname "docker-$(date +%s)" \
        --volume "${HOME}/src/:/root/src:ro" \
        --workdir /root \
        "${@}"

{ set +x ;} &> /dev/null
