# builtin alias path='builtin printf "%s\n" "${PATH//:/$'\''\n'\''}"'

# Sudo
builtin alias apt-get='/usr/bin/sudo /usr/bin/apt-get'
builtin alias apt='/usr/bin/sudo /usr/bin/apt'
builtin alias dnf='/usr/bin/sudo /usr/bin/dnf'
builtin alias pacman='/usr/bin/sudo /usr/bin/pacman'

# Functionality
builtin alias nnn='/usr/bin/nnn -d -H -i -J -o -x'
builtin alias less='/usr/bin/less -R'
builtin alias curl='/usr/bin/curl --ipv4'
builtin alias wget="/usr/bin/wget --inet4-only --hsts-file ${XDG_CACHE_HOME}/wget-hsts"
builtin alias bashly='/usr/bin/docker run --rm -it --user "$(/usr/bin/id -u):$(/usr/bin/id -g)" --volume "$HOME/src/bashly:/app" dannyben/bashly'
builtin alias completely='/usr/bin/docker run --rm -it --user "$(/usr/bin/id -u):$(/usr/bin/id -g)" --volume "$HOME/src/completely:/app" dannyben/completely'
builtin alias colourify='/usr/bin/grc --stderr --stdout'
builtin alias mpv='/usr/bin/mpv --hwdec=vaapi-copy --profile=high-quality'
builtin alias fastfetch='/usr/bin/fastfetch --config none --logo none --key-type both'

# Colors
builtin alias diff='/usr/bin/diff --color=auto'
builtin alias ls='/usr/bin/ls --color=auto'
builtin alias grep='/usr/bin/grep --color=auto'
builtin alias ip='/usr/bin/ip --color=auto'
builtin alias watch='/usr/bin/watch --color'

# Verbosity
builtin alias chgrp='/usr/bin/chgrp --verbose'
builtin alias chmod='/usr/bin/chmod --verbose'
builtin alias chown='/usr/bin/chown --verbose'
builtin alias cp='/usr/bin/cp --verbose'
builtin alias ln='/usr/bin/ln --verbose'
builtin alias mkdir='/usr/bin/mkdir --verbose --parents'
builtin alias mv='/usr/bin/mv --verbose'
builtin alias rm='/usr/bin/rm --verbose --force --recursive --interactive=once'
builtin alias rmdir='/usr/bin/rmdir --verbose'
builtin alias rsync='/usr/bin/rsync --verbose'

# builtin alias dotfiles='command git --git-dir ${REPODIR} --work-tree ${HOME}'
