#!/usr/bin/env bash

function usage () {
    Treset=$(tput sgr0)
    Tbold=$(tput bold)
    Titalic=$(tput sitm)
    Tunderline=$(tput ul)
    Treverse=$(tput rev)
    Tdim=$(tput dim)
    cat << EOF
${Treverse}${Tbold} DESCRIPTION ${Treset}
Upgrade packages on the system

${Treverse}${Tbold} SYNTAX ${Treset}
$ ${0##*/} <option>

${Treverse}${Tbold} OPTIONS ${Treset}
1p      apk, apt, dnf, pacman, pamac
3p      code, docker, flatpak, pipx, snap
all     upgrade everything
user    create user
help    show help

${Treverse}${Tbold} USAGE ${Treset}
$ ${0##*/} all
$ ${0##*/} apt code docker pipx
$ ${0##*/} help
EOF
}

# helpers

# function show() { printf '\033[7m # %s \033[0m\n' "${*}"; eval "${@}"; }
function check () { command -v "${1}" &> /dev/null; }
function header() { printf "\033[7m # %s - %s \033[0m\n" "$(date +%H:%M:%S)" "${1}"; }
function show () { (set -x; "${@:?}"); }
function text () { printf "%s\n" "${1}"; }

# function prompt_user () {
#     printf "%s\n" "${1}"
#     read -p "Input: " -n 1 -r answer
#     text ''
#     if [[ ! "${answer}" =~ ^[Yy]$ ]]; then
#         return
#     fi
# }

function elevate_user () {
    if [[ "$(id -ur)" -eq 0 ]]; then
        ELEVATE=""
    else
        if check sudo ; then
            ELEVATE="sudo"
        elif check sudo-rs; then
            ELEVATE="sudo-rs"
        elif check doas; then
            ELEVATE="doas"
        else
            text 'sudo, sudo-rs, doas not found in PATH'
            exit
        fi
    fi
}

create_user() {
    detect_virtualization() {
        if check systemd-detect-virt; then
            virt="$(systemd-detect-virt)"
        elif check virt-what; then
            virt="$(virt-what)"
        else
            virt=""
        fi
    }

    user_exists() {
        grep -q "^${DKRUSER}:" /etc/passwd
    }

    create_groups() {
        show ${ELEVATE:-} groupadd --force --gid 27 sudo
        show ${ELEVATE:-} groupadd --force --gid 28 wheel
        show ${ELEVATE:-} groupadd --force --gid 29 adm
    }

    create_user_account() {
        show ${ELEVATE:-} useradd --create-home --shell /bin/bash "${DKRUSER}"
        show ${ELEVATE:-} passwd "${DKRUSER}"
        for grp in sudo wheel adm; do
            show ${ELEVATE:-} usermod --append --groups "$grp" "${DKRUSER}"
        done
    }

    setup_sudoers() {
        ${ELEVATE:-} mkdir -p /etc/sudoers.d/
        cat << EOF | ${ELEVATE:-} tee /etc/sudoers.d/custom &>/dev/null
%wheel ALL=(ALL:ALL) ALL
%sudo  ALL=(ALL:ALL) ALL
${DKRUSER} ALL=(ALL:ALL) ALL
EOF
    }

    setup_shells() {
        # root profile
        cat << EOF | ${ELEVATE:-} tee /root/.profile &>/dev/null
[[ -f /root/.bashrc ]] && . /root/.bashrc
EOF
        # root bash
        cat << 'EOF' | ${ELEVATE:-} tee /root/.bashrc &>/dev/null
[[ "${-}" != *i* ]] && return
[[ -z "${BASH_COMPLETION_VERSINFO}" ]] && source /usr/share/bash-completion/bash_completion
PS1="\u@\h \w\n\$ "
EOF
        # user profile
        ${ELEVATE:-} rm "/home/${DKRUSER}/.bash_profile"
        cat << EOF | ${ELEVATE:-} tee "/home/${DKRUSER}/.profile" &>/dev/null
[[ -f . /home/${DKRUSER}/.bashrc ]] && . /home/${DKRUSER}/.bashrc
EOF
        # user bash
        cat << 'EOF' | ${ELEVATE:-} tee "/home/${DKRUSER}/.bashrc" &>/dev/null
[[ "${-}" != *i* ]] && return
[[ -z "${BASH_COMPLETION_VERSINFO}" ]] && source /usr/share/bash-completion/bash_completion
PS1="\u@\h \w\n\$ "
EOF
        # user permission
        ${ELEVATE:-} chown "${DKRUSER}:${DKRUSER}" "/home/${DKRUSER}/.profile" &>/dev/null
        ${ELEVATE:-} chown "${DKRUSER}:${DKRUSER}" "/home/${DKRUSER}/.bashrc" &>/dev/null
    }

    show_users() {
        header 'current users'
        awk -F: '$3 == 0 || $3 >= 1000' /etc/passwd | sort | while read -r line; do
            show echo "$line"
        done

        header 'user details'
        awk -F: '$3 == 0 || $3 >= 1000 {print $1}' /etc/passwd | while read -r usr; do
            show ${ELEVATE:-} id "$usr"
        done

        header 'login'
        text "sudo --user ${DKRUSER} --login"
    }

    # ----- Execution -----
    header 'create user'
    detect_virtualization

    if [[ "${virt}" == "none" ]]; then
        text 'user setup not needed'
        return
    fi

    read -r -p 'Enter name: ' DKRUSER
    DKRUSER="$(echo "${DKRUSER}" | xargs)"  # Trim whitespace

    if user_exists; then
        text "User '${DKRUSER}' already exists on this system."
        show getent passwd "${DKRUSER}"
        return
    fi

    create_groups
    create_user_account
    setup_sudoers
    setup_shells
    show_users
}



function pause_script {
    head="${1}"
    msg="${2}"
    prompt="${3}"
    header "${head}"
    echo "${msg}"
    read -r -n 1 -p "${prompt}"
}

function upgrade_apt {
    header 'apt'
    if command -v apt &> /dev/null; then
        DEBIAN_FRONTEND="noninteractive"; export DEBIAN_FRONTEND
        show ${ELEVATE:-} apt clean
        show ${ELEVATE:-} apt update
        show ${ELEVATE:-} apt full-upgrade
        show ${ELEVATE:-} apt install --assume-yes bash bash-completion curl dialog git nano sudo vim wget
        show ${ELEVATE:-} apt purge --autoremove
    else
        text 'apt not found in PATH'
    fi
}

function upgrade_apk {
    header 'apk'
    if command -v apk &> /dev/null; then
        show ${ELEVATE:-} apk cache clean
        show ${ELEVATE:-} apk update
        show ${ELEVATE:-} apk upgrade --progress
        show ${ELEVATE:-} apk add bash bash-completion curl wget ncurses git nano sudo shadow vim virt-what
    else
        text 'apk not found in PATH'
    fi
}

function upgrade_dnf {
    header 'dnf'
    if command -v dnf &> /dev/null; then
        show ${ELEVATE:-} dnf clean all
        show ${ELEVATE:-} dnf upgrade --refresh --assumeyes
        show ${ELEVATE:-} dnf install --assumeyes bash bash-completion curl wget ncurses git nano procps-ng vim xclip
        show ${ELEVATE:-} dnf autoremove
    else
        text 'dnf not found in PATH'
    fi
}

function upgrade_pacman {
    header 'pacman'
#     # https://gitlab.archlinux.org/archlinux/packaging/packages/pacman/-/blob/main/pacman.conf
#     # https://gitlab.archlinux.org/archlinux/packaging/packages/pacman/-/raw/main/pacman.conf
#     # cat /tmp/pacman.conf | grep -v '^#' | sed 's/ \{2,\}/ /g' | awk NF
#     # for VM/containers : DisableSandbox
#     # for bare metal : DownloadUser = alpm
    if command -v pacman &> /dev/null; then
        text 'pacman found in PATH'
        header 'pacman.conf'
        if [ "$(find /etc/pacman.conf -type f -mmin +60 2>/dev/null)" ]; then
            text '/etc/pacman.conf was modified more than 60 minutes ago.'
            cat <<-'EOF' | ${ELEVATE:-} tee /etc/pacman.conf
[options]
Architecture = x86_64
HoldPkg = pacman glibc
ParallelDownloads = 8
LocalFileSigLevel = Optional
SigLevel = Required DatabaseOptional
#DownloadUser = alpm
DisableSandbox
#CheckSpace
Color
ILoveCandy
VerbosePkgLists

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist

#[endeavouros]
#Include = /etc/pacman.d/endeavouros-mirrorlist
#SigLevel = PackageRequired

#[chaotic-aur]
#Include = /etc/pacman.d/chaotic-mirrorlist
EOF
        else
            text '/etc/pacman.conf was modified less than 60 minutes ago.'
            text 'using existing pacman.conf'
        fi

        header 'pacman cache'
        show ${ELEVATE:-} find /var/cache/pacman/pkg/ -mindepth 1 -exec rm -f {} \;
        show ${ELEVATE:-} find /var/lib/pacman/sync/ -mindepth 1 -exec rm -f {} \;

        header 'pacman update'
        show ${ELEVATE:-} pacman -Syyu --needed --noconfirm reflector

        header 'reflector'
        if command -v reflector &> /dev/null; then

            if [ "$(find /etc/pacman.d/mirrorlist -type f -mmin +60 2>/dev/null)" ]; then
                text '/etc/pacman.d/mirrorlist was modified more than 60 minutes ago.'
                show ${ELEVATE:-} reflector --verbose --ipv4 --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
            else
                text '/etc/pacman.d/mirrorlist was modified less than 60 minutes ago.'
                text 'using existing /etc/pacman.d/mirrorlist'
            fi
        else
            text 'reflector is not available for this distribution'
        fi

        header 'pacman packages'
        show ${ELEVATE:-} pacman -Syu --needed --noconfirm base-devel bash bash-completion curl git micro pacman-contrib sudo wget

        header 'yay'
        if command -v yay &> /dev/null; then
            text 'yay is already installed.'
        else
            show rm -fr /tmp/yay-bin
            show git clone --depth=1 https://aur.archlinux.org/yay-bin.git /tmp/yay-bin

            # disable debug flag
            show cp -f /etc/makepkg.conf /etc/makepkg.conf.bak
            sed -i "/^OPTIONS=(/s/ *debug//" /etc/makepkg.conf

            # bypass root warning
            show cp -f /usr/sbin/makepkg /usr/sbin/makepkg.bak
            show sed -i "/exit \$E_ROOT/ s/^/#/g" /usr/sbin/makepkg

            show makepkg --dir /tmp/yay-bin --syncdeps --install --needed --noconfirm
        fi

        header 'pacman *.pacnew *.pacsave'
        show ${ELEVATE:-} find /etc -name '*.pacnew' 2> /dev/null
        show ${ELEVATE:-} find /etc -name '*.pacsave' 2> /dev/null
    else
        text 'pacman not found in PATH'
    fi
}

function upgrade_pamac {
    header 'pamac'
    if command -v pamac &> /dev/null; then
        text 'pamac found in PATH'
        header 'pacman.conf'
        if [ "$(find /etc/pamac.conf -type f -mmin +60 2>/dev/null)" ]; then
            text '/etc/pamac.conf was modified more than 60 minutes ago.'
            cat <<-'EOF' | ${ELEVATE:-} tee /etc/pamac.conf
#CheckAURUpdates
#CheckAURVCSUpdates
#CheckFlatpakUpdates
#DownloadUpdates
#EnableFlatpak
#EnableSnap
#KeepBuiltPkgs
#OfflineUpgrade
#OnlyRmUninstalled
#SimpleInstall
BuildDirectory = /var/tmp
EnableAUR
EnableDowngrade
KeepNumPackages = 1
MaxParallelDownloads = 8
NoUpdateHideIcon
RefreshPeriod = 0
RemoveUnrequiredDeps
EOF
        else
            text '/etc/pamac.conf was modified less than 60 minutes ago.'
            text 'using existing /etc/pamac.conf'
        fi

        header 'pamac cache'
        show pamac clean --no-confirm --keep 0 --verbose

        header 'pamac mirrors'
        if [ "$(find /etc/pacman.d/mirrorlist -type f -mmin +60 2>/dev/null)" ]; then
            text '/etc/pacman.d/mirrorlist was modified more than 60 minutes ago.'
            cat <<-'EOF' | ${ELEVATE:-} tee /etc/pacman.d/mirrorlist
Server = https://mirrors.manjaro.org/repo/stable/$repo/$arch
Server = https://mirrors2.manjaro.org/stable/$repo/$arch
Server = http://mirror.xeonbd.com/manjaro/$repo/$arch
EOF
        else
            text '/etc/pacman.d/mirrorlist was modified less than 60 minutes ago.'
            text 'using existing /etc/pacman.d/mirrorlist'
        fi

        header 'pamac update'
        show pamac upgrade --force-refresh --no-confirm --no-aur

        header 'pacman packages'
        show pamac install --no-confirm base-devel bash bash-completion curl git micro pacman-contrib sudo wget

        header 'yay'
        if command -v yay &> /dev/null; then
            text 'yay is already installed.'
        else
            pamac install yay
        fi

        header 'pacman *.pacnew *.pacsave'
        show ${ELEVATE:-} find /etc -name '*.pacnew' 2> /dev/null
        show ${ELEVATE:-} find /etc -name '*.pacsave' 2> /dev/null
    else
        text 'pacman not found in PATH'
    fi
}

function upgrade_snap {
    if command -v snap &> /dev/null; then
        header 'snap'
        show ${ELEVATE:-} snap refresh
        show ${ELEVATE:-} snap refresh --hold
        show ${ELEVATE:-} snap set system snapshots.automatic.retention=no
        ${ELEVATE:-} snap list --all --unicode=never --color=never | while read -r name version revision tracking publisher notes; do
            if [[ "${notes}" = *disabled* ]]; then
                echo "${name}" "${version}" "${tracking}" "${publisher}" "${notes}"
                show ${ELEVATE:-} snap remove --purge "${name}" --revision="${revision}"
            fi; done
        unset name version revision tracking publisher notes
        #sudo snap remove --purge $(sudo snap list --all | awk 'NR > 1 {print $1}' | xargs)
    fi
}

function upgrade_flatpak {
    if command -v flatpak &> /dev/null; then
        header 'flatpak'
        show flatpak --user update --appstream --assumeyes
        show flatpak --user update --assumeyes
        show flatpak --user uninstall --unused --delete-data --assumeyes
        show flatpak --system update --appstream --assumeyes
        show flatpak --system update --assumeyes
        show flatpak --system uninstall --unused --delete-data --assumeyes
    fi
}

function upgrade_code {
    if command -v code &> /dev/null; then
        header 'code'
        show code --list-extensions
        show code --update-extensions
    fi
}

function upgrade_docker {
    if command -v docker &> /dev/null; then
        header 'docker'
        show docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"
        DOCKER_CLI_HINTS="false"; export DOCKER_CLI_HINTS
        for img in $(docker images --format "{{.Repository}}:{{.Tag}}"); do
            show docker pull "${img}"
        done
    fi
}

function upgrade_pipx {
    if command -v pipx &> /dev/null; then
        header 'pipx'
        show pipx list --short
        show pipx upgrade-all
    fi
}

function set_shell {
    if command -v systemd-detect-virt &> /dev/null; then
        virt="$(systemd-detect-virt)"
    elif command -v virt-what &> /dev/null; then
        virt="$(virt-what)"
    else
        virt=""
    fi

    header 'bash'
    if [[ "${virt}" = "none" ]]; then
        text 'shell setup not needed'
    else
        text 'bash; source /usr/share/bash-completion/bash_completion; PS1="\u@\h \w\n\$ "'
    fi
}

function upgrade_1p () {
    upgrade_apk
    upgrade_apt
    upgrade_dnf
    upgrade_pacman
    upgrade_pamac
}

function upgrade_3p () {
    upgrade_snap
    upgrade_flatpak
    upgrade_code
    upgrade_docker
    upgrade_pipx
}

function upgrade_all () {
    upgrade_1p
    upgrade_3p
}

function handle_arguments {
    if [[ "${#}" -eq 0 ]]; then
        usage
        exit 1
    fi

    local -a unique_args=()
    local arg
    local found

    for arg in "${@}"; do
        found="false"
        for existing_arg in "${unique_args[@]}"; do
            if [[ "${arg}" == "${existing_arg}" ]]; then
                found="true"
                break
            fi
        done
        if [[ "${found}" == false ]]; then
            unique_args+=("${arg}")
        fi
    done

    local upgrade_all_executed="false"

    for arg in "${unique_args[@]}"; do
        case "${arg}" in
            all)        if [[ "${upgrade_all_executed}" == false ]]; then upgrade_all; upgrade_all_executed="true"; fi ;;
            1p)         upgrade_1p      ;;
            3p)         upgrade_3p      ;;
            apk)        upgrade_apk     ;;
            apt)        upgrade_apt     ;;
            code)       upgrade_code    ;;
            dnf)        upgrade_dnf     ;;
            docker)     upgrade_docker  ;;
            flatpak)    upgrade_flatpak ;;
            pacman)     upgrade_pacman  ;;
            pamac)      upgrade_pamac   ;;
            pipx)       upgrade_pipx    ;;
            snap)       upgrade_snap    ;;
            user)       create_user     ;;
            help)       usage; exit     ;;
            *)          usage; exit 1 ;;
        esac
    done
}

function main {
    elevate_user
    handle_arguments "${@}"
}

# begin script from here
main "${@}"
