#[[ $# -eq 0 ]] && builtin printf "usage: %s <args>\n" "${FUNCNAME[0]}" && builtin return 1
#[[ $# -ne 0 ]] && builtin printf "usage: %s\n" "${FUNCNAME[0]}" && builtin return 1
# [[ "${1:-}" =~ ^(--help|-help|-h)$ ]] && /usr/bin/mybinary --help && builtin type myfunction && builtin return 0

function adeploy() {
    [[ $# -ne 0 ]] && builtin printf "usage: %s\n" "${FUNCNAME[0]}" && builtin return 1
    /usr/bin/adb push ~/src/stuff/linux/android/dwn /storage/emulated/0/src/dwn && /usr/bin/adb shell 'chmod +x /storage/emulated/0/src/dwn'
    /usr/bin/adb push ~/src/stuff/linux/android/shrc /storage/emulated/0/src/shrc && /usr/bin/adb shell 'chmod +x /storage/emulated/0/src/shrc'
}

function testscript () {
    [[ $# -ne 1 ]] && builtin printf "usage: %s filename\n" "${FUNCNAME[0]}" && builtin return 1

    builtin local SCRIPT_NAME="${1}"
    builtin local SCRIPT_DIR="${HOME}/src/stuff/linux/scripts"
    builtin local SCRIPT_PATH="${SCRIPT_DIR}/${SCRIPT_NAME}"

    if [[ -e "${SCRIPT_PATH}" ]]; then
        builtin printf 'error: script already exists at %s\n' "${SCRIPT_PATH}"
        builtin return 1
    else
        /usr/bin/install -v -D -m 0755 /dev/null -- "${SCRIPT_PATH}"
    fi

    builtin printf "Run the script with bash %s\n" "${SCRIPT_PATH}"
    /usr/bin/code "${SCRIPT_PATH}"
}

function _strip-ansi() {
    /usr/bin/perl -pe 's/\e\[[0-9;?]*[ -\/]*[@-~]//g'
}

function _out-common() {
    [[ -t 0 ]]          && { builtin printf "usage:\n$ command | %s\n" "${FUNCNAME[1]}"; builtin return 1; }
    [[ "${#}" -lt 2 ]]  && { builtin printf "missing command\n"; builtin return 1; }
    local message="${1}"
    builtin shift
    local tmp
    tmp="$("/usr/bin/mktemp")" || builtin return 1
    _strip-ansi | /usr/bin/tee "${tmp}"
    if [[ ! -s "${tmp}" ]]; then
        builtin printf 'no stdout received\n'
        /usr/bin/rm -f "${tmp}"
        builtin return 1
    fi
    /usr/bin/cat "${tmp}" | "${@}"
    local status="${?}"
    /usr/bin/rm -f "${tmp}"
    [[ "${status}" -eq 0 ]] && builtin printf '%s\n' "${message}"
    builtin return "${status}"
}

function out-clipboard () { _out-common 'piped stdout to clipboard' /usr/bin/xclip -selection clipboard; }
function out-vscode () { _out-common 'piped stdout to vscode' /usr/bin/code -; }
function out-pasters () { _out-common 'piped stdout to paste.rs' /usr/bin/pastelo --instance paste.rs; }

function yay () { /usr/bin/yay --aur --singlelineresults --answerclean=None --answerdiff=None --answeredit=None "${@}"; }

function pacfg () {
    LC_ALL=C /usr/bin/find / \
        \( -path /proc -o -path /sys -o -path /run -o -path /dev \) -prune -o \
        -type f \( -iname '*.pacsave' -o -iname '*.pacnew' \) -print 2>/dev/null |
        LC_ALL=C /usr/bin/sort
}

function c () {
    /usr/bin/clear
}

function r () {
    /usr/bin/clear
    /usr/bin/reset
    builtin exec /usr/bin/bash
}

function ls () {
    LC_ALL=C /usr/bin/ls \
        --almost-all \
        --color=auto \
        --format=verbose \
        --group-directories-first \
        --indicator-style=file-type \
        --quoting-style=shell \
        --time-style=+%Y%m%d-%H%M%S \
        "$@"
}

function cd () {
    if [[ $# -eq 0 ]]; then
        builtin cd "${HOME}" || builtin return
    elif [[ $# -eq 1 ]]; then
        builtin cd "${1}" || builtin return
        if [ "$(/usr/bin/find . -mindepth 1 -maxdepth 1 -printf '.' | /usr/bin/head -c 50 | /usr/bin/wc -c)" -lt 50 ]; then
            ls .
        fi
    else
        builtin printf "%s\n" "too many arguments"
        builtin return 1
    fi
}

function clean () {
    /usr/bin/sudo /usr/bin/journalctl --rotate
    /usr/bin/sudo /usr/bin/journalctl --vacuum-size=1B
    /usr/bin/sudo /usr/bin/find /var/cache/pacman/pkg -maxdepth 1 -type d -name "download-*" -delete
    /usr/bin/yay -Scc
}

function replasma () {
    /usr/bin/systemctl --user restart plasma-plasmashell.service \
    && /usr/bin/sleep 3 \
    && /usr/bin/systemctl --no-pager --user --full status plasma-plasmashell.service
}

function testscript () {
    [[ $# -ne 1 ]] && builtin printf "usage: %s filename\n" "${FUNCNAME[0]}" && builtin return 1

    builtin local SCRIPT_NAME="${1}"
    builtin local SCRIPT_DIR="${HOME}/src/stuff/linux/scripts"
    builtin local SCRIPT_PATH="${SCRIPT_DIR}/${SCRIPT_NAME}"

    /usr/bin/install -v -D -m 0755 /dev/null "${SCRIPT_PATH}"
    /usr/bin/code "${SCRIPT_PATH}"
    builtin printf "Run the script with bash ${SCRIPT_PATH}\n"
}

function backup-data () {
    [[ $# -ne 1 ]] && builtin printf "usage: ${FUNCNAME[0]} <file/folder>\n" && builtin return 1

    builtin local src dir ts dst cmd

    src="${1}"
    dir="$(/usr/bin/dirname -- "${src}")"
    ts="$(/usr/bin/date +%Y%m%d%H%M%S)"
    dst="${src}-${ts}.bak"
    cmd=()

    [[ ! -e "${src}" ]] && builtin printf "error: not found: ${src}\n" && builtin return 1
    [[ "${src}" == "/" ]] && builtin printf "error: refusing to backup root directory\n" && builtin return 1
    [[ "${src}" == "/home" ]] && builtin printf "error: refusing to backup home directory\n" && builtin return 1

    if [[ ! -w "${dir}" && ${EUID} -ne 0 ]]; then
        cmd=(/usr/bin/sudo /usr/bin/cp -v -a -f -- "${src}" "${dst}")
    else
        cmd=(/usr/bin/cp -f -a -v -- "${src}" "${dst}")
    fi

    "${cmd[@]}"
}

function vscode-root () {
    if [[ $# -eq 0 ]]; then
        builtin printf "usage: /usr/bin/vscode-root [options] [path]\n"
        builtin return
    fi

    /usr/bin/sudo /usr/bin/rm -rf /tmp/vscode-root
    /usr/bin/sudo /usr/bin/mkdir -p /tmp/vscode-root/data/User
    /usr/bin/sudo /usr/bin/mkdir -p /tmp/vscode-root/extensions
    /usr/bin/sudo /usr/bin/cp -fv ~/.config/Code/User/settings.json /tmp/vscode-root/data/User/settings.json

    /usr/bin/sudo /usr/bin/code \
        --disable-chromium-sandbox \
        --disable-extensions \
        --locale en-US \
        --log off \
        --new-window \
        --no-sandbox \
        --sync off \
        --user-data-dir /tmp/vscode-root/data \
        --extensions-dir /tmp/vscode-root/extensions \
        "${@}"
}

function path ()
{
    builtin local dir EXISTS PRIORITY=1 MODIFIED EXEC

    IFS=':' builtin read -r -a PATHS <<< "${PATH}"

    for dir in "${PATHS[@]}"; do
        if [ -d "${dir}" ]; then
            EXISTS=Y

            EXEC=$(/usr/bin/find -L "${dir}" -mindepth 1 -maxdepth 1 \( -type f -o -type l \) -executable 2>/dev/null | /usr/bin/wc -l)

            MODIFIED=$(/usr/bin/stat -c %Y "${dir}" 2>/dev/null)
            MODIFIED=$(/usr/bin/date -d "@${MODIFIED:-0}" "+%Y-%m-%d %H:%M:%S")

            builtin printf "%s\t%s\t%s\t%s\t%s\n" "${dir}" "${EXISTS}" "${PRIORITY}" "${MODIFIED}" "${EXEC}"
            ((PRIORITY++))
        else
            EXISTS=N
            MODIFIED="-"
            EXEC=0

            builtin printf "%s\t%s\t%s\t%s\t%s\n" "${dir}" "${EXISTS}" "-" "${MODIFIED}" "${EXEC}"
        fi
    done | /usr/bin/column --table --separator $'\t' -N PATH,EXISTS,PRIORITY,MODIFIED,EXECUTABLES -R 3,5
}

function terminal-colors() {
    local text=" * "
    local bg fg

    for fg in $(seq 0 15); do
        printf "%02d|" "${fg}"
        for bg in $(seq 0 15); do
            printf "\033[48;5;%sm\033[38;5;%sm%s\033[0m|" "${bg}" "${fg}" "${text}"
        done
        printf "\n"
    done | column -t -s '|' \
        -N FG\\BG,00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15 \
        -R 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
}

function dbx-create() {
    [[ $# -ne 1 ]] && distrobox list && echo 'usage: dbx-create <image:tag>' && return
    distrobox create \
    --verbose \
    --yes \
    --image "${1}" \
    --name "${1//:/-}" \
    --hostname "distrobox-${1//:/-}" \
    --init
}

function dbx-enter() {
    [[ $# -ne 1 ]] && distrobox list && echo 'usage: dbx-enter <image:tag>' && return
    distrobox enter \
    --verbose \
    --name "${1}" \
    --clean-path \
    --no-workdir
}

function cpsync () {
    [[ $# -eq 0 ]] && echo 'usage: cpsync <src> <dest>' && return
    /usr/bin/rsync --verbose --recursive --no-inc-recursive --compress-level=0 --human-readable --progress --stats --ipv4 "${@}" && /usr/bin/sync
}

function sanitize() {
    usage() {
        printf '%s\n' \
            "usage:" \
            "  sanitize PATTERN FILE" \
            "  command | sanitize PATTERN"
        return 1
    }

    local ch file esc
    ch="${1-}"
    file="${2-}"

    [ -n "$ch" ] || { usage; return 1; }

    esc="$(printf '%s\n' "$ch" | sed 's/[\/&]/\\&/g')"

    case "$( [ -t 0 ]; echo $? ):${2:+set}" in
        0:)     usage ;;
        0:set)  sed -e '/^[[:blank:]]*$/d' -e "/^[[:blank:]]*${esc}/d" "$file" ;;
        1:set)  usage ;;
        1:)     sed -e '/^[[:blank:]]*$/d' -e "/^[[:blank:]]*${esc}/d" ;;
    esac
}

function git--log () {
    /usr/bin/git --no-pager log \
    --date=format:'%Y/%m/%d-%H:%M:%S' \
    --abbrev=8 \
    --pretty=format:'%at | %ad | %h | %s' | /usr/bin/sort
    echo
}

function _ps1_sign () {
    PS1='' PS2='' PS3='' PS4=''
    PS1+='\[\e]0;bash\a\]'
    PS1+='\$ '
    PS2='> '
    PS3='#? '
    PS4='+ '
}
