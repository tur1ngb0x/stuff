PROMPT_COMMAND='EXIT=$?; builtin history -a'
VIRTUAL_ENV_DISABLE_PROMPT='1'

PS1=''

# title (window)
PS1+='\[\e]0;[$(/usr/bin/date "+%Y-%m-%d %H:%M:%S")] \u at \h in \w\a\]'

# user (green)
PS1+='\[\e[1;32m\]\u@\h\[\e[0m\]'

# separator (space)
PS1+=' '

# directory (blue)
PS1+='\[\e[1;34m\]\w\[\e[0m\]'

# distrobox (cyan)
PS1+='$([[ -n $DISTROBOX_ENTER_PATH ]] && printf " \[\e[1;36m\](distrobox:%s)\[\e[0m\]" "$(source /etc/os-release; printf "%s" "$PRETTY_NAME")")'

# venv (magenta)
PS1+='$([[ -n $VIRTUAL_ENV ]] && printf " \[\e[1;35m\](venv:%s)\[\e[0m\]" "${VIRTUAL_ENV##*/}")'

# git branch (yellow)
PS1+='$(git rev-parse --git-dir &>/dev/null && printf " \[\e[1;33m\](git:%s)\[\e[0m\]" "$(git rev-parse --abbrev-ref HEAD 2>/dev/null)")'

# exit (red)
PS1+='$((( EXIT != 0 )) && printf " \[\e[1;31m\](exit:%s)\[\e[0m\]" "${EXIT}")'

# symbol
PS1+='\n\$ '

# if true; then
PS2=$'\e[2mcontinue>\e[0m '

# select opt in A B C; do echo "Option: ${opt}"; break; done
PS3=$'\e[2mselect> \e[0m'

# set -x; echo hello; set +x
PS4=$'\e[2m+ \e[0m'
