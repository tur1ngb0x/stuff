#### INTERACTIVE ####
[[ "${-}" != *i* ]] && builtin return

#### SHELL ####
builtin bind '"\e[A": history-search-backward'     # up arrow search backward in history
builtin bind '"\e[B": history-search-forward'      # down arrow search forward in history
builtin bind '"\e[Z": menu-complete-backward'      # shift+tab cycles backwards through completions
builtin bind 'set colored-completion-prefix on'    # highlights completion prefix in color
builtin bind 'set colored-stats on'                # display metadata indicators during completion
builtin bind 'set enable-bracketed-paste on'       # prevent copy pasted text from triggering keybindings
builtin bind 'set expand-tilde on'                 # expand ~/ to /home/<username>
builtin bind 'set mark-directories on'             # append / to directories
builtin bind 'set mark-modified-lines on'          # mark lines in history which were modified before execution
builtin bind 'set mark-symlinked-directories on'   # append slash to symlinks during completion
builtin bind 'set match-hidden-files on'           # include hidden files during completion
builtin bind 'set menu-complete-display-prefix on' # show typed prefix during completion
builtin bind 'set show-all-if-ambiguous on'        # list all matches automatically
builtin bind 'set show-all-if-unmodified on'       # list all possible completions in 1st tab
builtin bind 'set skip-completed-text on'          # do not reinsert already completed text
builtin bind 'set visible-stats on'                # show file metadata during completion
builtin bind 'TAB:menu-complete'                   # tab cycles forwards through completion
/usr/bin/stty -ixon                                # disable software flow control
builtin set -o noclobber                           # prevent > from overwriting files, use >| to force

builtin shopt -s autocd                            # cd by typing directory name
builtin shopt -s cdspell                           # auto fix minor typos after using cd command
builtin shopt -s checkwinsize                      # update lines and columns after each command
builtin shopt -s cmdhist                           # save multi line cmds as single entry in bash history
builtin shopt -s complete_fullquote                # enables quoting during completion
builtin shopt -s direxpand                         # expand variables for directories
builtin shopt -s dirspell                          # auto fix minor directory name typos during completion
builtin shopt -s globasciiranges                   # use ascii ordering instead of locale
builtin shopt -s histappend                        # append history instead of overwriting
builtin shopt -s histverify                        # edit history line before execution
builtin shopt -s interactive_comments              # enables comment support in interactive shells
builtin shopt -s progcomp                          # enable advanced completions
builtin shopt -s promptvars                        # expand shell variables

#### PATH ####
PATH="${HOME}/.local/bin:${PATH}"              # user binaries
PATH="${HOME}/src/stuff/linux/scripts:${PATH}" # user scripts
PATH="$(builtin printf '%s' "${PATH}" | /usr/bin/awk -v RS=: -v ORS= '!a[$0]++ {if (NR>1) printf(":"); printf("%s", $0) }')"
builtin export PATH

#### VARIABLES ####
BROWSER='brave';                                builtin export BROWSER                    # default browser
DOCKER_BUILDKIT="1"                             builtin export DOCKER_BUILDKIT            # enable docker buildkit
EDITOR="micro";                                 builtin export EDITOR                     # editor used by cli programs
GIT_EDITOR='micro';                             builtin export GIT_EDITOR                 # editor used by git
GIT_PAGER='most -s -t4 -w';                     builtin export GIT_PAGER                  # pager used by git
HISTCONTROL='ignorespace:ignoredups:erasedups'; builtin export HISTCONTROL                # make history cleaner
HISTFILESIZE='10000';                           builtin export HISTFILESIZE               # history max lines saved in disk
HISTSIZE='1000';                                builtin export HISTSIZE                   # history max lines saved in memory per session
HISTTIMEFORMAT='%Y%m%d-%H%M%S  ';               builtin export HISTTIMEFORMAT             # history line timestamp
LESS='FRSX'                                     builtin export LESS                       # F=quit if one screen, R=raw color, S=chop lines, X=no init
MANPAGER='most -s -t4 -w';                      builtin export MANPAGER                   # pager used by man
PAGER='most -s -t4 -w';                         builtin export PAGER                      # pager used by cli programs
VIRTUAL_ENV_DISABLE_PROMPT='1';                 builtin export VIRTUAL_ENV_DISABLE_PROMPT # disable venv name in PS1 prompt
VISUAL='micro';                                 builtin export VISUAL                     # editor used by gui programs

#### ALIASES ####
builtin unalias -a
# -----------------------------------------------------------------------------
builtin alias chgrp='/usr/bin/chgrp --verbose'
builtin alias chmod='/usr/bin/chmod --verbose'
builtin alias chown='/usr/bin/chown --verbose'
builtin alias cp='/usr/bin/cp --verbose'
builtin alias ln='/usr/bin/ln --verbose'
builtin alias mkdir='/usr/bin/mkdir --verbose --parents'
builtin alias mv='/usr/bin/mv --verbose'
builtin alias rm='/usr/bin/rm --verbose --force --interactive=once'
builtin alias rmdir='/usr/bin/rmdir --verbose'
builtin alias rmdir='/usr/bin/rmdir --verbose'
builtin alias rsync='/usr/bin/rsync --verbose'
builtin alias diff='/usr/bin/diff --color=auto'
builtin alias grep='/usr/bin/grep --color=auto'
builtin alias ip='/usr/bin/ip --color=auto'
builtin alias ls='/usr/bin/ls --color=auto'
builtin alias watch='/usr/bin/watch --color'
builtin alias apt-get='/usr/bin/sudo /usr/bin/apt-get'
builtin alias apt='/usr/bin/sudo /usr/bin/apt'
builtin alias bashly='/usr/bin/docker run --rm -it --user $(/usr/bin/id -u):$(/usr/bin/id -g) --volume ~/src/bashly:/app dannyben/bashly'
builtin alias colourify='/usr/bin/grc --stderr --stdout'
builtin alias completely='/usr/bin/docker run --rm -it --user $(/usr/bin/id -u):$(/usr/bin/id -g) --volume ~/src/completely:/app dannyben/completely'
builtin alias curl='/usr/bin/curl --ipv4'
builtin alias dnf='/usr/bin/sudo /usr/bin/dnf'
builtin alias less='/usr/bin/less -R'
builtin alias pacman='/usr/bin/sudo /usr/bin/pacman'

#### PROMPT ####
_ps1_sep()      { builtin printf -- '-%.0s' $(/usr/bin/seq 1 "${COLUMNS:-80}"); }
_ps1_exit()     { (( EXIT != 0 )) && builtin printf "\e[30;41m exit:%s \e[0m" "${EXIT}"; }
_ps1_userhost() { builtin printf "\e[30;42m %s@%s \e[0m" "${USER}" "${HOSTNAME}"; }
_ps1_dir()      { builtin printf "\e[30;46m %s \e[0m" "${PWD}"; }
#_ps1_venv()     { [[ -n "${VIRTUAL_ENV}" ]] && builtin printf "\e[30;45m venv:%s \e[0m" "$(/usr/bin/basename "${VIRTUAL_ENV}")"; }
_ps1_venv()     { [[ -n "${VIRTUAL_ENV}" ]] && builtin printf "\e[30;45m venv:%s:%s \e[0m" "$(/usr/bin/python --version 2>&1 | /usr/bin/awk '{print $2}')" "$(/usr/bin/basename "${VIRTUAL_ENV}")"; }
#_ps1_git()      { /usr/bin/git rev-parse --git-dir &>/dev/null && builtin printf "\e[30;43m git:%s \e[0m" "$(/usr/bin/git rev-parse --abbrev-ref HEAD 2>/dev/null)"; }
_ps1_git()      { /usr/bin/git rev-parse --git-dir &>/dev/null && builtin printf "\e[30;43m git:%s:%s \e[0m" "$(/usr/bin/git --version | /usr/bin/awk '{print $3}')" "$(/usr/bin/git rev-parse --abbrev-ref HEAD 2>/dev/null)"; }
PROMPT_COMMAND='EXIT=$?; builtin history -a'; export PROMPT_COMMAND
PS1='\[\e]0;\u@\h:\w\a\]$(_ps1_dir)$(_ps1_venv)$(_ps1_git)\n\$ '; export PS1

#### SOURCE ####
builtin source /usr/share/bash-completion/bash_completion 2>/dev/null
builtin source /usr/share/doc/pkgfile/command-not-found.bash 2>/dev/null
