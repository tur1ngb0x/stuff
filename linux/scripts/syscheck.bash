#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

usage() {
    cat <<EOF
Usage:
    $(basename "${0}")

Description:
    Check basic system status information.

Example:
    $(basename "${0}")
EOF
}

die() {
    printf '%s\n' "${1}" 1>&2
    exit 1
}

require() {
    local cmd
    for cmd in "${@}"; do
        command -v "${cmd}" >/dev/null 2>&1 || die "Missing required command: ${cmd}"
    done
}

arguments() {
    if [[ "${#}" -ne 0 ]]; then
        usage
        exit 1
    fi
}

separator() {
    printf '%s\n' "${1}"
}

print_system_info() {
    printf '%s\n' 'System Information'
    separator '------------------'
    printf 'Hostname: %s\n' "$(hostname)"
    printf 'Uptime: %s\n' "$(uptime -p 2>/dev/null || uptime)"
    printf 'Kernel: %s\n' "$(uname -r)"
    printf '%s\n' ''
}

print_cpu_info() {
    printf '%s\n' 'CPU Load'
    separator '--------'
    if [[ -r "/proc/loadavg" ]]; then
        awk '{printf "Load Average (1m,5m,15m): %s %s %s\n", $1, $2, $3}' /proc/loadavg
    else
        uptime
    fi
    printf '%s\n' ''
}

print_memory_info() {
    printf '%s\n' 'Memory Usage'
    separator '------------'
    if [[ -r "/proc/meminfo" ]]; then
        local mem_total mem_free
        mem_total="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
        mem_free="$(awk '/MemAvailable/ {print $2}' /proc/meminfo)"
        printf 'MemTotal: %s kB\n' "${mem_total}"
        printf 'MemAvailable: %s kB\n' "${mem_free}"
    else
        free -h
    fi
    printf '%s\n' ''
}

print_disk_info() {
    printf '%s\n' 'Disk Usage'
    separator '----------'
    df -h --output=source,size,used,avail,pcent,target 2>/dev/null || df -h
    printf '%s\n' ''
}

main() {
    arguments "${@}"
    require hostname uname uptime df awk

    print_system_info
    print_cpu_info
    print_memory_info
    print_disk_info
}

main "${@}"