#!/usr/bin/env bash

set -Eeuo pipefail

readonly ZRAM_MODULE="zram"
readonly ZRAM_DEVICE="/dev/zram0"
readonly ZRAM_SYSFS="/sys/block/zram0"
readonly ZRAM_ALGO="zstd"

readonly ZRAM_SIZE_PERCENT=50
readonly ZRAM_SIZE_GB=0

readonly ZRAM_PRIORITY=32767
readonly ZRAM_STREAMS=0
readonly ZRAM_MEM_LIMIT=0

readonly MODULE_FILE="/etc/modules-load.d/zram.conf"
readonly UNIT_FILE="/etc/systemd/system/zram.service"
readonly SCRIPT_FILE="/usr/local/libexec/zram.sh"

require_root() {
    (( EUID == 0 )) || {
        printf 'Error: must be run as root.\n' >&2
        exit 1
    }
}

write_file() {
    local file="${1}"
    local mode="${2}"
    local content="${3}"
    local tmp

    tmp="$(mktemp)"

    printf '%s' "${content}" > "${tmp}"

    if [[ ! -f "${file}" ]] || ! cmp -s "${tmp}" "${file}"; then
        install -D -m "${mode}" "${tmp}" "${file}"
    fi

    rm -f "${tmp}"
}

setup_module() {
    printf '%s\n' "${ZRAM_MODULE}"
}

setup_script() {
    cat <<EOF
#!/usr/bin/env bash

set -Eeuo pipefail

readonly DEVICE="${ZRAM_DEVICE}"
readonly SYSFS="${ZRAM_SYSFS}"

readonly ZRAM_SIZE_PERCENT=${ZRAM_SIZE_PERCENT}
readonly ZRAM_SIZE_GB=${ZRAM_SIZE_GB}

readonly ZRAM_ALGO="${ZRAM_ALGO}"
readonly ZRAM_PRIORITY=${ZRAM_PRIORITY}
readonly ZRAM_STREAMS=${ZRAM_STREAMS}
readonly ZRAM_MEM_LIMIT=${ZRAM_MEM_LIMIT}

if [[ "\$(<"\${SYSFS}/initstate")" == "1" ]]; then
    swapoff "\${DEVICE}" 2>/dev/null || true
    echo 1 > "\${SYSFS}/reset"
fi

memory_kib="\$(awk '/^MemTotal:/ { print \$2 }' /proc/meminfo)"
memory_gib=\$(( memory_kib / 1024 / 1024 ))

if (( ZRAM_SIZE_PERCENT > 0 )); then
    (( ZRAM_SIZE_PERCENT <= 100 )) || {
        printf 'Error: ZRAM_SIZE_PERCENT must be <= 100.\n' >&2
        exit 1
    }

    size_bytes=\$(( memory_kib * 1024 * ZRAM_SIZE_PERCENT / 100 ))

elif (( ZRAM_SIZE_GB > 0 )); then
    (( ZRAM_SIZE_GB <= memory_gib )) || {
        printf 'Error: ZRAM_SIZE_GB (%d) exceeds physical RAM (%d GiB).\n' \\
            "\${ZRAM_SIZE_GB}" "\${memory_gib}" >&2
        exit 1
    }

    size_bytes=\$(( ZRAM_SIZE_GB * 1024 * 1024 * 1024 ))

else
    printf 'Error: Configure either ZRAM_SIZE_PERCENT or ZRAM_SIZE_GB.\n' >&2
    exit 1
fi

echo "\${ZRAM_ALGO}" > "\${SYSFS}/comp_algorithm"

if (( ZRAM_MEM_LIMIT > 0 )); then
    echo "\${ZRAM_MEM_LIMIT}" > "\${SYSFS}/mem_limit"
fi

if (( ZRAM_STREAMS > 0 )); then
    echo "\${ZRAM_STREAMS}" > "\${SYSFS}/max_comp_streams"
fi

echo "\${size_bytes}" > "\${SYSFS}/disksize"

mkswap -f "\${DEVICE}" >/dev/null
swapon --priority "\${ZRAM_PRIORITY}" "\${DEVICE}"
EOF
}

setup_service() {
    cat <<EOF
[Unit]
Description=ZRAM Swap
After=systemd-modules-load.service
Requires=systemd-modules-load.service
Before=swap.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=${SCRIPT_FILE}
ExecStop=/usr/bin/swapoff ${ZRAM_DEVICE}
ExecStopPost=/usr/bin/bash -c 'echo 1 > ${ZRAM_SYSFS}/reset'

[Install]
WantedBy=multi-user.target
EOF
}

install_module() {
    write_file "${MODULE_FILE}" 0644 "$(setup_module)"
}

install_script() {
    write_file "${SCRIPT_FILE}" 0755 "$(setup_script)"
}

install_service() {
    write_file "${UNIT_FILE}" 0644 "$(setup_service)"
}

enable_service() {
    local unit

    unit="$(basename "${UNIT_FILE}")"

    systemctl daemon-reload
    systemctl enable --now "${unit}"
}

main() {
    require_root
    install_module
    install_script
    install_service
    enable_service
}

main "${@}"
