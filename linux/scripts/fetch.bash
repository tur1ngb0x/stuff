#!/usr/bin/env bash

get_distro(){
    . /etc/os-release

    builtin printf "DISTRO|%s\n" "${PRETTY_NAME}"
}

get_kernel(){
    local kernel

    kernel="$(< /proc/sys/kernel/osrelease)"

    builtin printf "KERNEL|%s%s\n" \
        "${kernel}" \
        "$([[ -f /var/run/reboot-required ]] && builtin printf ' %s' '(!)')"
}

get_init(){
    local init

    read -r init < /proc/1/comm

    builtin printf "INIT|%s\n" "${init}"
}

get_uptime(){
    local total d r h m s pct

    read -r total _ < /proc/uptime
    total="${total%.*}"

    d=$((total / 86400))
    r=$((total % 86400))

    h=$((r / 3600))
    r=$((r % 3600))

    m=$((r / 60))
    s=$((r % 60))

    pct=$((total * 100 / 86400))

    builtin printf "UPTIME|"

    (( d > 0 )) && builtin printf "%d " "${d}"

    builtin printf "%02d:%02d:%02d/24H (%d%%)\n" \
        "${h}" \
        "${m}" \
        "${s}" \
        "${pct}"
}

get_cpu(){
    local user1 nice1 sys1 idle1 iowait1 irq1 softirq1 steal1 guest1 guestn1
    local user2 nice2 sys2 idle2 iowait2 irq2 softirq2 steal2 guest2 guestn2
    local total1 total2 idle_total1 idle_total2
    local delta_total delta_idle usage

    read -r _ \
        user1 nice1 sys1 idle1 iowait1 irq1 softirq1 steal1 guest1 guestn1 \
        < /proc/stat

    sleep 0.1

    read -r _ \
        user2 nice2 sys2 idle2 iowait2 irq2 softirq2 steal2 guest2 guestn2 \
        < /proc/stat

    total1=$((user1 + nice1 + sys1 + idle1 + iowait1 + irq1 + softirq1 + steal1))
    total2=$((user2 + nice2 + sys2 + idle2 + iowait2 + irq2 + softirq2 + steal2))

    idle_total1=$((idle1 + iowait1))
    idle_total2=$((idle2 + iowait2))

    delta_total=$((total2 - total1))
    delta_idle=$((idle_total2 - idle_total1))

    (( delta_total == 0 )) && usage=0 || \
        usage=$(((delta_total - delta_idle) * 100 / delta_total))

    builtin printf "CPU|%d%%\n" "${usage}"
}

get_load(){
    local load1 load5 load15 _

    read -r load1 load5 load15 _ < /proc/loadavg

    builtin printf "LOAD|%s %s %s\n" \
        "${load1}" \
        "${load5}" \
        "${load15}"
}

get_shell(){
    local shell_name="${SHELL##*/}"
    local shell_version=""

    case "${shell_name}" in
        bash)
            shell_version=" ${BASH_VERSION%%(*}"
            ;;

        fish)
            shell_version=" $(/usr/bin/fish --version | /usr/bin/awk '{print $3}')"
            ;;

        zsh)
            shell_version=" $(/usr/bin/zsh --version | /usr/bin/awk '{print $2}')"
            ;;
    esac

    builtin printf "SHELL|%s%s\n" \
        "${shell_name}" \
        "${shell_version}"
}

get_disk(){
    builtin printf "DISK|%s\n" "$(
        /usr/bin/df --output=used,size / |
        /usr/bin/awk '
            FNR == 2 {
                used=$1/1024/1024
                total=$2/1024/1024

                printf "%.2f/%.2fG (%.0f%%)\n",
                    used,
                    total,
                    ($1/$2)*100
            }
        '
    )"
}

get_memory(){
    local total=0 available=0 used=0

    while read -r key value _; do
        case "${key}" in
            MemTotal:)
                total="${value}"
                ;;

            MemAvailable:)
                available="${value}"
                ;;
        esac
    done < /proc/meminfo

    used=$((total - available))

    builtin printf "MEMORY|%.2f/%.2fG (%d%%)\n" \
        "$(builtin printf '%f' "$((used))e-6")" \
        "$(builtin printf '%f' "$((total))e-6")" \
        "$((used * 100 / total))"
}

get_battery(){
    local level status full=0 design=0 health

    read -r level < /sys/class/power_supply/BAT1/capacity
    read -r status < /sys/class/power_supply/BAT1/status
    read -r full < /sys/class/power_supply/BAT1/charge_full
    read -r design < /sys/class/power_supply/BAT1/charge_full_design

    health="$(/usr/bin/awk -v f="${full}" -v d="${design}" '
        BEGIN {
            printf "%.1f", (f / d) * 100
        }
    ')"

    builtin printf "BATTERY|%s%% %s (%s%%)\n" \
        "${level}" \
        "${status}" \
        "${health}"
}

get_swap(){
    local total=0 available=0 used=0

    while read -r _ _ size used_part _; do
        total=$((total + size))
        used=$((used + used_part))
    done < <(
        /usr/bin/awk 'NR > 1' /proc/swaps
    )

    (( total == 0 )) && {
        builtin printf "SWAP|None\n"
        return
    }

    available=$((total - used))

    builtin printf "SWAP|%.2f/%.2fG (%d%%)\n" \
        "$(builtin printf '%f' "$((used))e-6")" \
        "$(builtin printf '%f' "$((total))e-6")" \
        "$((used * 100 / total))"
}

get_session(){
    builtin printf "SESSION|%s (%s)\n" \
        "${XDG_SESSION_DESKTOP:-Unknown}" \
        "${XDG_SESSION_TYPE:-Unknown}"
}

main(){
    get_distro
    get_kernel
    get_init
    get_shell
    get_session
    get_uptime
    get_disk
    get_memory
    get_swap
}

main "${@}" | /usr/bin/column -s '|' -o ' = ' -R 1 -t
