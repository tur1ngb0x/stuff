#!/usr/bin/env bash

LC_ALL=C
set -euo pipefail

# set base directory
BASEDIR="${HOME}/src"

# get list of git repositories from base directory
builtin readarray -t REPOS < <(command -p find "${BASEDIR}" -type d -name '.git' | command -p sort)

# loop through each repo in base directory
for REPO in "${REPOS[@]}"; do
	# remove .git from repo
	REPO="${REPO%.git}"
	# print repo name and git remote
	builtin printf "\n\033[1;7m%s\033[0m - " "${REPO}"
	command -p git --no-pager --git-dir="${REPO}/.git" --work-tree="${REPO}" remote --verbose | command -p awk 'NR==1 {print $2}'
	# show git status
	command -p git --no-pager --git-dir="${REPO}/.git" --work-tree="${REPO}" status --short --branch
done

unset BASEDIR

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

