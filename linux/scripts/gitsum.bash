#!/usr/bin/env bash

set -o nounset
set -o pipefail

readonly GIT_STATUS_CMD=(
    git
    status
    --porcelain=v1
    -z
)

declare root=""
declare gitdir=""
declare branch=""
declare remote_url=""

declare c_reset=""
declare c_rev=""
declare c_mod=""
declare c_add=""
declare c_del=""
declare c_ren=""
declare c_untracked=""
declare c_other=""
declare c_dir=""

declare -a modified=()
declare -a added=()
declare -a deleted=()
declare -a renamed=()
declare -a untracked=()
declare -a others=()

sanitize()
{
    printf '%s' "$1" | tr -d '\000-\011\013-\037\177'
}

is_interactive_terminal()
{
    [[ -t 1 ]]
}

load_colors()
{
    if ! is_interactive_terminal; then
        return 0
    fi

    c_reset="$(tput sgr0 2> /dev/null || printf '\033[0m')"
    c_rev="$(tput rev 2> /dev/null || printf '\033[7m')"

    c_mod="$(tput setaf 3 2> /dev/null || printf '\033[33m')"
    c_add="$(tput setaf 2 2> /dev/null || printf '\033[32m')"
    c_del="$(tput setaf 1 2> /dev/null || printf '\033[31m')"
    c_ren="$(tput setaf 6 2> /dev/null || printf '\033[36m')"
    c_untracked="$(tput setaf 5 2> /dev/null || printf '\033[35m')"
    c_other="$(tput setaf 7 2> /dev/null || printf '\033[37m')"

    c_dir="$(tput bold 2> /dev/null || printf '\033[1m')"
    c_dir+="$(tput setaf 4 2> /dev/null || printf '\033[34m')"
}

validate_repo()
{
    if ! gitdir="$(git rev-parse --git-dir 2> /dev/null)"; then
        printf 'error: not a git repository\n' >&2
        exit 1
    fi

    if ! root="$(git rev-parse --show-toplevel 2> /dev/null)"; then
        printf 'error: cannot determine repository root\n' >&2
        exit 1
    fi
}

detect_branch()
{
    branch="$(git branch --show-current 2> /dev/null)"

    if [[ -z "$branch" ]]; then
        branch="detached@$(git rev-parse --short HEAD 2> /dev/null)"
    fi
}

detect_remote()
{
    remote_url="$(
        git remote get-url origin 2> /dev/null \
        || git remote get-url "$(git remote | head -n1)" 2> /dev/null \
        || printf 'no remote'
    )"
}

render_item()
{
    local item="$1"

    item="$(sanitize "$item")"

    if [[ -d "$item" ]]; then
        printf '%s%s%s\n' \
            "$c_dir" \
            "$item" \
            "$c_reset"
    else
        printf '%s\n' "$item"
    fi
}

render_items()
{
    local items=("$@")

    printf '%s\0' "${items[@]}" \
    | sort -z \
    | while IFS= read -r -d '' item; do
        render_item "$item"
    done
}

print_section()
{
    local title="$1"
    local color="$2"

    shift 2

    local items=("$@")
    local count="${#items[@]}"

    (( count == 0 )) && return 0

    printf '\n%s%s%s%s: %d\n' \
        "$c_rev" \
        "$color" \
        "$title" \
        "$c_reset" \
        "$count"

    render_items "${items[@]}"
}

print_metadata()
{
    printf '\n%s%sProject%s\n' \
        "$c_rev" \
        "$c_other" \
        "$c_reset"

    printf '%s\n' "$(sanitize "$root")"

    printf '\n%s%sRemote%s\n' \
        "$c_rev" \
        "$c_other" \
        "$c_reset"

    printf '%s\n' "$(sanitize "$remote_url")"
}

classify_entry()
{
    local code="$1"
    local path="$2"

    case "$code" in
        M)
            modified+=("$path")
        ;;

        A)
            added+=("$path")
        ;;

        D)
            deleted+=("$path")
        ;;

        R)
            renamed+=("$path")
        ;;

        \?)
            untracked+=("$path")
        ;;

        *)
            others+=("$path")
        ;;
    esac
}

parse_status_stream()
{
    local entry=""
    local status=""
    local file=""
    local target=""
    local x=""
    local y=""
    local code=""
    local full=""

    while IFS= read -r -d '' entry; do

        status="${entry:0:2}"
        file="${entry:3}"

        x="${status:0:1}"
        y="${status:1:1}"

        if [[ "$status" == '??' ]]; then
            classify_entry '?' "$root/$file"
            continue
        fi

        if [[ "$x" == 'R' || "$x" == 'C' ]]; then
            if ! IFS= read -r -d '' target; then
                printf 'error: malformed rename entry\n' >&2
                continue
            fi

            file="$target"
        fi

        if [[ "$x" != ' ' ]]; then
            code="$x"
        else
            code="$y"
        fi

        full="$root/$file"

        classify_entry "$code" "$full"

    done < <("${GIT_STATUS_CMD[@]}")
}

render_output()
{
    print_metadata

    print_section "Branch" "$c_other" "$branch"

    print_section "Modified" "$c_mod" "${modified[@]}"
    print_section "Added" "$c_add" "${added[@]}"
    print_section "Deleted" "$c_del" "${deleted[@]}"
    print_section "Renamed" "$c_ren" "${renamed[@]}"
    print_section "Untracked" "$c_untracked" "${untracked[@]}"
    print_section "Other" "$c_other" "${others[@]}"
}

main()
{
    load_colors

    validate_repo

    detect_branch

    detect_remote

    parse_status_stream

    render_output
}

main "$@"

#                +-------+
#                |       |
#                | stash |
#                |       |
#                +-------+
# +---------+   +---------+   +-----------+   +------------+
# |         |   |         |   |           |   |            |
# | workdir |   | staging |   | localrepo |   | remoterepo |
# |         |   |         |   |           |   |            |
# +---------+   +---------+   +-----------+   +------------+

# workdir - staging
# git add -p | git add -A | git rm | git mv
# git restore --staged <path>   # remove from index
# git reset <path>              # unstage (older form)
# git diff                      # workdir vs index
# git diff --staged / --cached  # index vs HEAD

# workdir - stash
# git stash push [-m msg] --include-untracked/-u --all/-a
# git stash list
# git stash show -p
# git stash apply | git stash pop
# git stash drop | git stash clear

# workdir - localrepo
# git commit -m "msg"
# git commit -a -m "msg"        # skip staging for tracked files
# git commit --amend             # modify last commit

# staging - localrepo
# git commit                     # commit staged changes
# git commit --amend             # add staged to last commit
# git diff --cached              # inspect staged diff

# localrepo - remoterepo
# git remote add <name> <url>
# git fetch [remote]             # update remote refs
# git pull [--rebase]            # fetch + merge/rebase into workdir
# git push [--set-upstream|-u]   # push commits
# git push --tags
# git push --force-with-lease    # safe force-push

