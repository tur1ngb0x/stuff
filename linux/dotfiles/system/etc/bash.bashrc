# INTERACTIVE
[[ "${-}" != *i* ]] && builtin return

# COMPLETION
builtin source /usr/share/bash-completion/bash_completion

# OPTIONS
builtin shopt -s checkwinsize
builtin shopt -s histappend

# PROMPT
PROMPT_COMMAND='builtin history -a'
PS1='\[\e]0;\u@\h \w\a\]\u@\h \w\n\$ '

# ALIASES
builtin unalias -a
builtin alias diff='/usr/bin/diff --color=auto'
builtin alias grep='/usr/bin/grep --color=auto'
builtin alias ip='/usr/bin/ip --color=auto'
builtin alias ls='/usr/bin/ls --color=auto'
builtin alias watch='/usr/bin/watch --color'
