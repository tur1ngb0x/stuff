# INTERACTIVE
[[ -z "${PS1}" ]] && builtin return

# COMPLETION
[[ -f /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion

# OPTIONS
builtin shopt -s checkwinsize
builtin shopt -s histappend

# PROMPT
PROMPT_COMMAND='builtin history -a'
PS1='\u@\h \w\n\$ '
PS1="\[\e]0;\u@\h \w\a\]${PS1}"

# ALIASES
builtin alias diff='command -p diff --color=auto'
builtin alias grep='command -p grep --color=auto'
builtin alias ip='command -p ip --color=auto'
builtin alias ls='command -p ls --color=auto'
builtin alias watch='command -p watch --color'
