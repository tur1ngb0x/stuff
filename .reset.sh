#!/usr/bin/env --ignore-environment --split-string bash --noprofile --norc

# debugging
set -o errexit
set -o xtrace

# requirements
for i in git dos2unix find; do
    if ! command -v "${i}" &>/dev/null; then
        echo "${i} not found"
        exit 1
    fi
done

# git config
for i in user.name user.email ; do
    if ! git config --global --get "${i}" &>/dev/null; then
        echo "git ${i} not set"
        exit 1
    fi
done

# variables
cwd="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P --)"
git_user="tur1ngb0x"
git_repo="stuff"
git_url="https://github.com/${git_user:?}/${git_repo:?}.git"

# backup repo
cp --archive "${cwd}" "${cwd}.bak-$(date +%Y%m%d-%H%M%S)"

# delete metadata
rm --force --recursive "${cwd}/.git"

# fix line ending
find "${cwd}" -type f -exec dos2unix --quiet "{}" +
find "${cwd}/windows" -type f -exec unix2dos --quiet "{}" +

# fix permission
find "${cwd}" -type d -exec chmod 0755 "{}" +
find "${cwd}" -type f -exec chmod 0644 "{}" +
find "${cwd}/linux/scripts" -type f -exec chmod 0755 "{}" +

# fix ownership
find "${cwd}" -exec chown "${USER}:${USER}" "{}" +

# move into repo
pushd "${cwd}" &>/dev/null

# set branch
git init --quiet --initial-branch 'main'

# add remote
git remote add origin "${git_url}"

# add files
git add --all

# commit files
GIT_AUTHOR_DATE="1970-01-01 00:00:00 +0000" GIT_COMMITTER_DATE="1970-01-01 00:00:00 +0000" git commit --quiet --allow-empty --allow-empty-message --message ''

# push remote
git push --quiet --force --ipv4 --set-upstream origin main

# exit repo
popd &>/dev/null

# show files w/o ending newline
# find "${cwd}" -path '*/.git' -prune -o -type f -exec sh -c 'for f do [ "$(tail -c1 "$f")" != "" ] && printf "%s\n" "$f"; done' sh {} + | LC_ALL=C sort
