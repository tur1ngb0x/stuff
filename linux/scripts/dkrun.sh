#!/usr/bin/env bash

# check for tool
if [[ -x "/usr/bin/docker" ]]; then
    TOOL="/usr/bin/docker"
elif [[ -x "/usr/bin/podman" ]]; then
    TOOL="/usr/bin/podman"
else
    echo "install docker/podman to continue"
    exit 1
fi

# docker checks
if [[ "${TOOL}" == "/usr/bin/docker" ]]; then
    if ! groups | grep -q "\bdocker\b"; then
        echo "error: user not in docker group"
        exit 1
    fi

    if ! systemctl is-active --quiet docker; then
        echo "error: docker service is not running"
        exit 1
    fi
fi

{ set -x ;} &> /dev/null

"${TOOL}" container run \
    --interactive \
    --tty \
    --cpus 2 \
    --memory 2G \
    --memory-swap 0 \
    --user root \
    --hostname "docker-$(/usr/bin/date +%s)" \
    --volume "${HOME}/src/:/root/src:ro" \
    --workdir /root \
    "${@:?}"

{ set +x ;} &> /dev/null

