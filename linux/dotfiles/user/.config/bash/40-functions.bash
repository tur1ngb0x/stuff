#[[ $# -eq 0 ]] && builtin printf "usage: %s <args>\n" "${FUNCNAME[0]}" && builtin return 1
#[[ $# -ne 0 ]] && builtin printf "usage: %s\n" "${FUNCNAME[0]}" && builtin return 1
# [[ "${1:-}" =~ ^(--help|-help|-h)$ ]] && /usr/bin/mybinary --help && builtin type myfunction && builtin return 0

flatpak-search() {
    /usr/bin/flatpak search --columns=name,application "${1:?Enter search term}" |
    LC_ALL=C /usr/bin/sort -u -t $'\t' -k1,1 |
    /usr/bin/awk -F '\t' '
    {
        rows[NR,1] = $1
        rows[NR,2] = $2
        if (length($1) > max)
            max = length($1)
    }
    END {
        printf "%*s  %s\n", max, "NAME", "APPLICATION"
        for (i = 1; i <= NR; i++)
            printf "%*s  %s\n", max, rows[i,1], rows[i,2]
    }'
}

function search-find () {
    builtin local path="${1:?search-find '$path' '$term' '$find_args'}"
    builtin local term="${2:?search-find '$path' '$term' '$find_args'}"
    builtin shift 2
    /usr/bin/sudo LC_ALL=C /usr/bin/find "${path}" -iname "*${term}*" "${@}" \
    | LC_ALL=C /usr/bin/sort \
    | while IFS= read -r line; do printf "'\033[32m%s\033[0m'\n" "${line}"; done
}

function search-grep () {
    builtin local path="${1:?search-grep 'path' 'term' '$grep_args'}"
    builtin local term="${2:?search-grep 'path' 'term' '$grep_args'}"
    builtin shift 2
    /usr/bin/sudo LC_ALL=C /usr/bin/grep --recursive --binary-files=without-match --with-filename --line-number --color=always "${@}" "${term}" "${path}" \
    | LC_ALL=C /usr/bin/sort
}

bash-show() {
    local types="alias|arrayvar|binding|builtin|command|directory|disabled|enabled|export|file|function|group|helptopic|hostname|job|keyword|running|service|setopt|shopt|signal|stopped|user|variable"

    case "|$types|" in
        *"|$1|"*)
            compgen -A "$1" | LC_ALL=C /usr/bin/sort -u | column
            ;;
        *)
            printf 'Usage:\nbash-show <option>\n\nOptions:\n'
            printf '%s\n' "${types//|/$'\n'}" | column
            return 1
            ;;
    esac
}

function bash-cmd () {
    [[ $# -eq 0 ]] && builtin printf "usage: %s <command>\n" "${FUNCNAME[0]}" && builtin return 1

    builtin local file="$(builtin command mktemp --suffix=.md)"

    [[ -z ${file-} ]] && return

    (
        builtin printf '\033[7m# Input:\033[0m\n'
        builtin printf '```\n'
        builtin printf '$ %s\n' "$*"
        builtin printf '```\n'
        builtin printf '\033[7m# Output:\033[0m\n'
        builtin printf '```\n'
        builtin eval "${@:?}"
        builtin printf '```\n'
    ) |& builtin command tee >(
        builtin command sed -r 's/\x1B(\[[0-9;]*[A-Za-z]|\][^\a]*\a)//g' \
        | builtin command tee "${file}" \
        | builtin command xclip -selection clipboard
    )
    # /usr/bin/code "${file}" &>/dev/null
}

catwhich () {
    /usr/bin/cat -n -- "$(/usr/bin/which ${1:?})"
}

label_image() {
    local input="${1:?Usage: label_image image meal nutrition}"
    local meal="${2:?}"
    local nutrition="${3:?}"

    magick "$input" \
        -resize '1080x1080>' \
        -fill white \
        -undercolor '#000000BF' \
        -gravity south \
        -pointsize 72 \
        -annotate +0+100 "$meal" \
        -pointsize 36 \
        -annotate +0+40 "$nutrition" \
        output.jpg
}

label_image() {
    local input="${1:?Usage: label_image input.jpg protein_g fat_g carb_g meal_name}"
    local protein="${2:?Protein content in grams}"
    local fat="${3:?Fat content in grams}"
    local carbs="${4:?Carbs content in grams}"
    local meal="${5:?Meal name}"
    output=$(sed -E 's/.*/\L&/; s/[^a-z0-9]+/_/g; s/^_+|_+$//g' <<<"${meal}").jpg

    local resize='1080x1080>'
    local font='/usr/share/fonts/Adwaita/AdwaitaSans-Regular.ttf'
    local undercolor='#000000BF'

    [[ -f "$input" ]] || {
        printf 'error: %s not found\n' "${input}" >&2
        return 1
    }

    local dim
    dim=$(magick "${input}" -resize "${resize}" -format '%[fx:min(w,h)]' info:)

    local meal_ps=$(( dim / 15 ))
    local nutrition_ps=$(( dim / 30 ))
    local meal_y=$(( meal_ps + dim / 100 ))
    local nutrition_y=$(( dim / 50 ))

    local kcal
    kcal=$(awk -v p="$protein" -v f="$fat" -v c="$carbs" \
        'BEGIN { printf "%.0f", p*4 + f*9 + c*4 }')

    local nutrition
    nutrition="Energy ${kcal} kcal    Protein ${protein}g    Fat ${fat}g    Carbs ${carbs}g"

    magick "${input}" \
        -resize "${resize}" \
        -fill white \
        -undercolor "${undercolor}" \
        -font "${font}" \
        -gravity south \
        -pointsize "${meal_ps}" \
        -annotate +0+"${meal_y}" "${meal}" \
        -pointsize "${nutrition_ps}" \
        -annotate +0+"${nutrition_y}" "${nutrition}" \
        -quality 100 \
        "${output}"
    file $(readlink -f ${output})
}

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

function out-bathelp ()   { _out-common 'piped stdout to bat' bat --style numbers --language help "${@}"; }
function out-batman ()    { _out-common 'piped stdout to bat' bat --style numbers --language man "${@}"; }
function out-clipboard () { _out-common 'piped stdout to clipboard' /usr/bin/xclip -selection clipboard; }
function out-vscode ()    { _out-common 'piped stdout to vscode' /usr/bin/code -; }
function out-pasters ()   { _out-common 'piped stdout to paste.rs' /usr/bin/pastelo --instance paste.rs; }

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
        --date=format:'%Y/%m/%d %H:%M:%S' \
        --abbrev=8 \
        --pretty=format:'%ad | %h | %s' |
    /usr/bin/sed -E 's/^([^|]*\| )([0-9a-f]+)( \| .*)/\1\U\2\E\3/' | /usr/bin/sort

    builtin echo
}

function git--log () {
    /usr/bin/git --no-pager log \
        --date=format:'%Y/%m/%d %H:%M:%S' \
        --abbrev=8 \
        --pretty=format:'%ad | %h | %s' \
        | /usr/bin/sort \
        | /usr/bin/awk '
        BEGIN {
            FS = " \\| "

            cyan  = "\033[36m"
            green = "\033[32m"
            reset = "\033[0m"

            date_re = "^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$"
            hash_re = "^[0-9a-f]{8}$"
        }

        NF == 3 &&
        $1 ~ date_re &&
        $2 ~ hash_re {
            printf "%s%s%s | %s%s%s | %s\n",
                green,  $1, reset,
                cyan, toupper($2), reset,
                $3
        }
        '
}

function git--log () {
    /usr/bin/git --no-pager log \
    --date=format:'%Y%m%d-%H%M%S' \
    --abbrev=8 \
    --pretty=format:'%ad | %h | %s' | /usr/bin/sort -r | /usr/bin/fzf \
    --no-sort \
    --exact \
    --padding=0 \
    --margin=0 \
    --delimiter=' \| ' \
    --with-nth=1,3 \
    --header="YYYYMMDD-HHMMSS | COMMIT" \
    --prompt='search> ' \
    --preview='git --no-pager show --color=always {2}'
}

function _ps1_sign () {
    PS1='' PS2='' PS3='' PS4=''
    PS1+='\[\e]0;bash\a\]'
    PS1+='\$ '
    PS2='> '
    PS3='#? '
    PS4='+ '
}
