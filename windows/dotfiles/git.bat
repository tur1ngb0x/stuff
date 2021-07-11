@ECHO OFF

powershell.exe rm "$HOME/.gitconfig"

git config --global user.name "tur1ngb0x"
git config --global user.email "25666761+tur1ngb0x@users.noreply.github.com"
git config --global color.ui true
git config --global core.autocrlf true
git config --global core.editor "code --new-window --wait"
git config --global credential.helper "cache --timeout=7200" 

git config --list

pause
