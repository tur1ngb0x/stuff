PROMPT_COMMAND='EXIT=$?; builtin history -a'
VIRTUAL_ENV_DISABLE_PROMPT='1'

PS1=''

# title (window)
PS1+='\[\e]0;[\D{%Y-%m-%d %H:%M:%S}] \u at \h in \w\a\]'

# # bash (grey)
# PS1+='$([[ -n $BASH_VERSION ]] && builtin printf "\[\e[1;90m\](bash:%s)\[\e[0m\]" "${BASH_VERSION%%(*}")'

# # separator (space)
# PS1+=' '

# user (green)
PS1+='\[\e[1;32m\]\u@\h\[\e[0m\]'

# separator (space)
PS1+=' '

# directory (blue)
PS1+='\[\e[1;34m\]\w\[\e[0m\]'

# distrobox (cyan)
PS1+='$([[ -n $DISTROBOX_ENTER_PATH ]] && builtin printf " \[\e[1;36m\](distrobox:%s)\[\e[0m\]" "$(builtin source /etc/os-release; builtin printf "%s" "$PRETTY_NAME")")'

# venv (magenta)
PS1+='$([[ -n $VIRTUAL_ENV ]] && builtin printf " \[\e[1;35m\](venv:%s)\[\e[0m\]" "${VIRTUAL_ENV##*/}")'

# git branch (yellow)
#PS1+='$(git rev-parse --git-dir &>/dev/null && builtin printf " \[\e[1;33m\](git:%s)\[\e[0m\]" "$(git rev-parse --abbrev-ref HEAD 2>/dev/null)")'
PS1+='$(git rev-parse --git-dir &>/dev/null && printf " \[\e[1;33m\](git:%s%s)\[\e[0m\]" "$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" "$([[ -n $(git status --porcelain 2>/dev/null) ]] && printf "*")")'

# exit (red)
PS1+='$((( EXIT != 0 )) && builtin printf " \[\e[1;31m\](exit:%s)\[\e[0m\]" "${EXIT}")'

# separator (space)
PS1+=' '

# symbol
PS1+='\$ '

# if true; then
PS2=$'\e[2mcontinue>\e[0m '

# select opt in A B C; do echo "Option: ${opt}"; break; done
PS3=$'\e[2mselect> \e[0m'

# set -x; echo hello; set +x
PS4=$'\e[2m+ \e[0m'

[[ -f /usr/bin/fastfetch ]] && /usr/bin/fastfetch --config none --logo none --key-type both
