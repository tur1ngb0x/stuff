#!/usr/bin/env bash

function confirm () {
    builtin read -r -p 'Continue? [y/N] ' answer
    builtin printf '%s\n' ''
    [[ "${answer}" == [Yy] ]] || builtin exit 1
}

function repocheck () {
    builtin local LC_ALL=C
    builtin export LC_ALL

    builtin local gitdir
    if ! gitdir="$(/usr/bin/git rev-parse --git-dir 2>/dev/null)"; then
        builtin printf '%s\n' 'error: Current directory is not a git repository'
        builtin return 1
    fi

    builtin local root
    if ! root="$(/usr/bin/git rev-parse --show-toplevel 2>/dev/null)"; then
        builtin printf '%s\n' 'error: Cannot determine repository root in current directory'
        builtin return 1
    fi

    # local cwd="$(builtin cd -- "$(/usr/bin/dirname -- "${BASH_SOURCE[0]}")" && builtin pwd -P --)"
    builtin local cwd
    cwd="${root}"

    function header ()  { builtin printf '\033[1;38;5;190m# %s\033[0m\n' "${1}"; }
    function get ()     { /usr/bin/find "${cwd:-.}" \( -path '*/.git' -prune \) -o "${@}"; }
    function gettext () { get \( -type f -exec /usr/bin/grep -Iq . "{}" \; -print \) ;}
    function format ()  { /usr/bin/sort -u | /usr/bin/column -s '|' -o '|' -R 2,3 -t; }

    # FILE SYSTEM CHECKS
    header 'File names containing whitespace'
    get \( -type f -name "*[[:space:]]*" -exec /usr/bin/sh -c 'for f do printf "%s | L1 | C1\n" "$f"; done' sh {} + \) | format

    header 'Binary files'
    get \( -type f -exec /usr/bin/sh -c 'for f do if ! /usr/bin/grep -Iq . "$f"; then printf "%s | L1 | C1\n" "$f"; fi; done' sh {} + \) | format

    header 'Empty files'
    get \( -type f -empty -exec /usr/bin/sh -c 'for f do printf "%s | L1 | C1\n" "$f"; done' sh {} + \) | format

    header 'Symbolic links'
    get \( -type l -exec /usr/bin/sh -c 'for f do printf "%s | L1 | C1\n" "$f"; done' sh {} + \) | format

    # TEXT CHECKS
    header 'Files containing non-ASCII characters'
    get \( -type f -exec /usr/bin/awk '{ for (i = 1; i <= length($0); i++) { c = substr($0, i, 1); if (c ~ /[^\x00-\x7F]/) { printf "%s | L%d | C%d\n", FILENAME, FNR, i } } }' {} + \) | format

    header 'Files without ending newline'
    get \( -type f -exec /usr/bin/sh -c 'for f do if [ -s "$f" ] && [ "$(/usr/bin/tail -c 1 "$f" | /usr/bin/wc -l)" -eq 0 ]; then /usr/bin/awk "END { printf \"%s | L%d | C%d\\n\", FILENAME, NR, length(\$0)+1 }" "$f"; fi; done' sh {} + \) | format

    header 'Files containing trailing whitespaces'
    get \( -type f -exec /usr/bin/awk '{ match($0, /[[:blank:]]+$/); if (RSTART) printf "%s | L%d | C%d\n", FILENAME, FNR, RSTART }' {} + \) | format

    header 'Files containing tab characters'
    get \( -type f -exec /usr/bin/awk '{ for (i = 1; i <= length($0); i++) if (substr($0, i, 1) == "\t") printf "%s | L%d | C%d\n", FILENAME, FNR, i }' {} + \) | format

    header 'Files containing multiple shebangs'
    get \( -type f -exec /usr/bin/awk 'FNR > 1 && /^#!/ { printf "%s | L%d | C1\n", FILENAME, FNR }' {} + \) | format

    header 'Files containing consecutive blank lines'
    get \( -type f -exec /usr/bin/awk 'FNR == 1 { blank=0 } /^$/{ if(blank) printf "%s | L%d | C1\n", FILENAME, FNR; blank=1; next } { blank=0 }' {} + \) | format

    header 'Files which are executables without shebang'
    get \( -type f -perm -111 -exec /usr/bin/sh -c 'for f do /usr/bin/head -n1 "$f" | /usr/bin/grep -q "^#!" || printf "%s | L1 | C1\n" "$f"; done' sh {} + \) | format

    builtin unset -v cwd gitdir root
    builtin unset -f header get format
}

# requirements
for i in chmod chown cp date dirname dos2unix find git id pwd sed tree unix2dos xdg-open; do
    if [[ ! -x "/usr/bin/${i}" ]]; then
        builtin printf "/usr/bin/%s not found\n" "${i}"
        builtin exit 1
    fi
done

# git config
for i in user.name user.email ; do
    if ! /usr/bin/git config --global --get "${i}" &>/dev/null; then
        builtin echo "git ${i} not set"
        builtin exit 1
    fi
done

# variables
cwd="$(builtin cd -- "$(/usr/bin/dirname -- "${BASH_SOURCE[0]}")" && builtin pwd -P --)"
git_user="tur1ngb0x"
git_repo="stuff"
git_url="https://github.com/${git_user:?}/${git_repo:?}.git"

# verify remote
builtin printf '%s\n' "Target remote: ${git_url}"
confirm

# run diagnostics
builtin printf '%s\n' "Run repo diagnostics?"
confirm
repocheck

# proceed
builtin printf '%s\n' "Proceed with reset?"
confirm

# debugging
builtin set -o errexit
builtin set -o nounset
builtin set -o pipefail
builtin set -o xtrace

# backup repo
/usr/bin/cp --archive "${cwd}" "${cwd}.bak-$(/usr/bin/date +%Y%m%d-%H%M%S)"

# delete metadata
[[ -d "${cwd}/.git" ]] && /usr/bin/find "${cwd}/.git" -depth -delete

# add README.md
/usr/bin/tree -d -L 2 --charset ascii --noreport "${cwd}" | /usr/bin/sed "1s|.*|${git_repo}|" | /usr/bin/sed -e '1i ```' -e '$a ```' >| "${cwd}/README.md"

# fix line ending
/usr/bin/find "${cwd}" -type f -exec /usr/bin/dos2unix --quiet "{}" +
/usr/bin/find "${cwd}/windows" -type f -exec /usr/bin/unix2dos --quiet "{}" +

# fix permission
/usr/bin/find "${cwd}" -type d -exec /usr/bin/chmod 0755 "{}" +
/usr/bin/find "${cwd}" -type f -exec /usr/bin/chmod 0644 "{}" +
/usr/bin/find "${cwd}/linux/scripts" -maxdepth 1 -type f -exec /usr/bin/chmod 0755 "{}" +

# fix ownership
/usr/bin/find "${cwd}" -exec /usr/bin/chown "${USER}:${USER}" "{}" +

# move into repo
builtin pushd "${cwd}" &>/dev/null

# set branch
/usr/bin/git init --quiet --initial-branch 'main'

# add remote
/usr/bin/git remote add origin "${git_url}"

# add files
/usr/bin/git add --all

# commit files
GIT_AUTHOR_DATE="1970-01-01 00:00:00 +0000" \
GIT_COMMITTER_DATE="1970-01-01 00:00:00 +0000" \
/usr/bin/git commit --quiet --allow-empty --allow-empty-message --message ''

# push remote
/usr/bin/git push --quiet --force --ipv4 --set-upstream origin main

# exit repo
builtin popd &>/dev/null

# open remote
/usr/bin/sleep 5
/usr/bin/xdg-open "${git_url}"

# debugging disable
builtin set +o errexit
builtin set +o nounset
builtin set +o pipefail
builtin set +o xtrace
