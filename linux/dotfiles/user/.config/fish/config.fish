# exit if non-interactive
if not status is-interactive
    return
end

# disable greeting
set fish_greeting

# start starship
if type -fq starship
    if starship init fish | source
        printf '%s' 'welcome to $(command -v fish) $(command -v starship)'
    end
end

