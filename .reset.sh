#!/usr/bin/env --ignore-environment --split-string bash --noprofile --norc

set -ex

cwd="$(cd "$(dirname "$0")" && pwd -P)"

cp --archive "${cwd}" "${cwd}.bak-$(date +%Y%m%d-%H%M%S)"

pushd "${cwd}" &>/dev/null

rm --force --recursive "${cwd}/.git"

git init --quiet --initial-branch 'main'

git add --all

GIT_AUTHOR_DATE="1970-01-01 00:00:00 +0000" GIT_COMMITTER_DATE="1970-01-01 00:00:00 +0000" git commit --quiet --allow-empty --allow-empty-message --message ''

git remote add origin https://github.com/tur1ngb0x/stuff.git

git push --quiet --force --ipv4 --set-upstream origin main

popd &>/dev/null

# # force strict mode
# builtin set -euxo pipefail

# # force posix locale
# LC_ALL="C"; export LC_ALL

# # force PATH
# PATH='/usr/local/sbin:/usr/local/bin:/usr/bin'; export PATH

# # set repo details
# GHUSER="tur1ngb0x"
# GHREPO="stuff"
# GHURL="https://github.com/${GHUSER:?}/${GHREPO:?}.git"

# header() {
#     builtin printf '\n\n\n\n\n\033[1;34;7m %s \033[0m\n' "${1:?header text required}"
# }

# header 'getting current working directory'
# cwd="$(
#     builtin cd -- "$(/usr/bin/dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 &&
#     builtin pwd -P
# )"

# header 'backing up repository'
# /usr/bin/cp --verbose --archive -- "${cwd}" "${cwd}.bak-$(/usr/bin/date +%Y%m%d-%H%M%S)"

# header 'entering repository'
# builtin pushd -- "${cwd}"

# header 'removing repository metadata'
# /usr/bin/rm --verbose --recursive --force -- "${cwd}/.git"

# header 'fixing line endings'
# /usr/bin/find -- "${cwd}" -type f -exec /usr/bin/dos2unix --verbose -- "{}" +
# /usr/bin/find -- "${cwd}/windows" -type f -exec /usr/bin/unix2dos --verbose -- "{}" +

# header 'fixing permissions'
# /usr/bin/find -- "${cwd}" -type d -exec /usr/bin/chmod --verbose -- 0755 "{}" +
# /usr/bin/find -- "${cwd}" -type f -exec /usr/bin/chmod --verbose -- 0644 "{}" +

# header 'fixing ownership'
# /usr/bin/find -- "${cwd}" -exec /usr/bin/chown --verbose -- "${USER}:${USER}" "{}" +

# header 'creating repository'
# /usr/bin/git init --initial-branch 'main'

# header 'setting origin'
# /usr/bin/git remote add -- origin "${GHURL}"

# header 'adding files'
# /usr/bin/git add --verbose --all -- "${cwd}"

# header 'commiting files'
# GIT_AUTHOR_DATE="1970-01-01 00:00:00 +0000" \
# GIT_COMMITTER_DATE="1970-01-01 00:00:00 +0000" \
# /usr/bin/git commit --verbose --allow-empty --allow-empty-message --message ''

# header 'pushing to remote'
# /usr/bin/git push --verbose --set-upstream --force -- origin main

# header 'exiting repository'
# builtin popd --
