#!/usr/bin/env bash

/usr/bin/rm -fv "$HOME/.gitconfig"
/usr/bin/rm -fv "$HOME/.config/git/config"

/usr/bin/git config --global user.name "tur1ngb0x"
/usr/bin/git config --global user.email "25666761+tur1ngb0x@users.noreply.github.com"
/usr/bin/git config --global color.ui always
/usr/bin/git config --global color.branch always
/usr/bin/git config --global color.decorate always
/usr/bin/git config --global color.diff always
/usr/bin/git config --global color.grep always
/usr/bin/git config --global color.interactive always
/usr/bin/git config --global color.pager true
/usr/bin/git config --global color.showbranch always
/usr/bin/git config --global color.status always
/usr/bin/git config --global core.autocrlf input # Linux = input | Windows = true
/usr/bin/git config --global core.editor "nano -w" # Linux = nano -w | Windows = "code --new-window --wait"
/usr/bin/git config --global credential.helper "cache --timeout=7200" 

/usr/bin/git config --list
