[[ $- != *i* ]] && return

bash_custom() {
    local file; local -a bash_modules=(
        00-options
        10-path
        20-variables
        30-aliases
        40-functions
        50-prompt
    )
    for file in "${bash_modules[@]}"; do source "${HOME}/src/stuff/linux/dotfiles/user/.config/bash/${file}.bash"; done
}

# load custom bash config
bash_custom
