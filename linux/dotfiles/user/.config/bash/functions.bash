#[[ $# -eq 0 ]] && builtin printf "usage: %s <args>\n" "${FUNCNAME[0]}" && builtin return 1
#[[ $# -ne 0 ]] && builtin printf "usage: %s\n" "${FUNCNAME[0]}" && builtin return 1
# [[ "${1:-}" =~ ^(--help|-h)$ ]] && /usr/bin/mybinary --help && builtin type myfunction && builtin return 1

function yay () { /usr/bin/yay --aur --singlelineresults "${@}"; }

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
        --color=always \
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

function disk () {
    /usr/bin/du -h -d1 -- "${1:-$PWD}" 2>/dev/null \
    | LC_ALL=C /usr/bin/sort -hr \
    | /usr/bin/awk '
    BEGIN {
        yellow = "\033[33m"
        cyan   = "\033[36m"
        green  = "\033[32m"
        reset  = "\033[0m"
    }
    {
        size = $1
        path = substr($0, index($0, $2))

        color = ""
        if (size ~ /G$/) {
            color = yellow
        } else if (size ~ /M$/) {
            color = cyan
        } else if (size ~ /K$/) {
            color = green
        }

        num  = substr(size, 1, length(size) - 1)
        unit = substr(size, length(size), 1)

        printf "%s%4s%s %s\n", color, num unit, reset, path
    }'
}

function replasma () {
    /usr/bin/systemctl --user restart plasma-plasmashell.service \
    && /usr/bin/sleep 3 \
    && /usr/bin/systemctl --no-pager --user --full status plasma-plasmashell.service
}

function testscript () {
    [[ $# -ne 1 ]] && builtin printf "Usage: %s filename\n" "${FUNCNAME[0]}" && builtin return 1

    builtin local SCRIPT_NAME="${1}.bash"
    builtin local SCRIPT_DIR="${HOME}/src/stuff/linux/scripts"
    builtin local SCRIPT_PATH="${SCRIPT_DIR}/${SCRIPT_NAME}"

    /usr/bin/install -v -D -m 0755 /dev/null "${SCRIPT_PATH}"
    /usr/bin/code "${SCRIPT_PATH}" || /usr/bin/zed "${SCRIPT_PATH}" || "${EDITOR}" "${SCRIPT_PATH}"
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
    --image "${1:?}" \
    --name "${1//:/-}" \
    --hostname "distrobox-${1//:/-}" \
    --init
}

function dbx-enter() {
    [[ $# -ne 1 ]] && distrobox list && echo 'usage: dbx-enter <image:tag>' && return
    distrobox enter \
    --verbose \
    --name "${1:?}" \
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
            "  command | sanitize PATTERN" >&2
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

function pacman-search() {
    if [ $# -ne 1 ]; then
        printf 'usage: pacman-search <query>\n' >&2
        return 1
    fi

    local query="$1"
    local line desc meta
    local component package version status group

    pacman -Ss "$query" |
    while IFS= read -r line; do
        if [[ $line =~ ^([^/[:space:]]+)/([^[:space:]]+)[[:space:]]+([^[:space:]]+)(.*)$ ]]; then
            component="${BASH_REMATCH[1]}"
            package="${BASH_REMATCH[2]}"
            version="${BASH_REMATCH[3]}"
            meta="${BASH_REMATCH[4]}"

            status=""
            group=""

            [[ $meta == *"[installed]"* ]] && status='[I]'

            if [[ $meta =~ \(([^()]*)\) ]]; then
                group="${BASH_REMATCH[1]}"
            fi

            IFS= read -r desc || desc=""
            desc="${desc#"${desc%%[![:space:]]*}"}"

            printf '%s|%s|%s|%s|%s|%s\n' \
                "$status" "$package" "$version" "$component" "$group"
        fi
    done |
    LC_ALL=C sort -t '|' -k1,1 -k5,5 |
    column -s '|' -N STATUS,PACKAGE,VERSION,COMPONENT,GROUP -t
}

#######################################################################################################################
# GIT
#######################################################################################################################
function git--log () {
    git --no-pager log \
    --date=format:'%Y/%m/%d-%H:%M:%S' \
    --abbrev=8 \
    --pretty=format:'%at | %ad | %h | %s' | sort
    echo
}

function git--status ()
{
    local root gitdir;
    if ! gitdir="$(git rev-parse --git-dir)"; then
        printf "error: not a git repository\n" 1>&2;
        return 1;
    fi;
    if ! root="$(git rev-parse --show-toplevel)"; then
        printf "error: cannot determine repository root\n" 1>&2;
        return 1;
    fi;
    local c_reset c_rev c_mod c_add c_del c_ren c_untracked c_other;
    c_reset="$(tput sgr0 2> /dev/null || printf '\033[0m')";
    c_rev="$(tput rev 2> /dev/null || printf '\033[7m')";
    c_mod="$(tput setaf 3 2> /dev/null || printf '\033[33m')";
    c_add="$(tput setaf 2 2> /dev/null || printf '\033[32m')";
    c_del="$(tput setaf 1 2> /dev/null || printf '\033[31m')";
    c_ren="$(tput setaf 6 2> /dev/null || printf '\033[36m')";
    c_untracked="$(tput setaf 5 2> /dev/null || printf '\033[35m')";
    c_other="$(tput setaf 7 2> /dev/null || printf '\033[37m')";
    local branch;
    branch="$(git rev-parse --abbrev-ref HEAD)";
    local modified=();
    local deleted=();
    local added=();
    local renamed=();
    local untracked=();
    local others=();
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue;
        local status="${line:0:2}";
        local file="${line:3}";
        if [[ "$status" == "??" ]]; then
            untracked+=("$root/$file");
            continue;
        fi;
        local x="${status:0:1}";
        local y="${status:1:1}";
        local code;
        if [[ "$x" != " " ]]; then
            code="$x";
        else
            code="$y";
        fi;
        local full="$root/$file";
        case "$code" in
            D)
                deleted+=("$full")
            ;;
            R)
                renamed+=("$full")
            ;;
            A)
                added+=("$full")
            ;;
            M)
                modified+=("$full")
            ;;
            *)
                others+=("$full")
            ;;
        esac;
    done < <(git status --porcelain);
    function print_section ()
    {
        local title="$1";
        local color="$2";
        shift 2;
        local items=("$@");
        local count="${#items[@]}";
        local c_dir;

        (( count == 0 )) && return;

        c_dir="$(tput bold 2> /dev/null || printf '\033[1m')$(tput setaf 4 2> /dev/null || printf '\033[34m')";

        printf "\n%s%s%s:%s %d\n" "$c_rev" "$color" "$title" "$c_reset" "$count";

        printf '%s\n' "${items[@]}" | sort | while IFS= read -r item; do
            if [[ -d "$item" ]]; then
                printf "%s%s%s\n" "$c_dir" "$item" "$c_reset"
            else
                printf "%s\n" "$item"
            fi
        done
    }
    print_section "Branch" "$c_other" "$branch";
    print_section "Modified" "$c_mod" "${modified[@]}";
    print_section "Added" "$c_add" "${added[@]}";
    print_section "Deleted" "$c_del" "${deleted[@]}";
    print_section "Renamed" "$c_ren" "${renamed[@]}";
    print_section "Untracked" "$c_untracked" "${untracked[@]}";
    print_section "Other" "$c_other" "${others[@]}"
}

function fzf--file () {
    local file
    file="$(fzf)" && "${EDITOR}" "${file}"
}

function _ps1_user_host_dir_newline_sign () {
    PS1='' PS2='' PS3='' PS4=''
    PS1+='\[\e]0;\u@\h \w\a\]'
    PS1+='\u@\h \w\n\$ '
    PS2='> '
    PS3='#? '
    PS4='+ '
}

function _ps1_dir_newline_sign () {
    PS1='' PS2='' PS3='' PS4=''
    PS1+='\[\e]0;\w\a\]'
    PS1+='\w\n\$ '
    PS2='> '
    PS3='#? '
    PS4='+ '
}

function _ps1_sign () {
    PS1='' PS2='' PS3='' PS4=''
    PS1+='\[\e]0;bash\a\]'
    PS1+='\$ '
    PS2='> '
    PS3='#? '
    PS4='+ '
}
