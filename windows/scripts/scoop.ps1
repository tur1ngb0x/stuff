# scoop.ps1 — Minimal Scoop Installer

# Allow script execution
# Set-ExecutionPolicy Bypass -Scope LocalMachine -Force

#######################################################################################################################
# INSTALL SCOOP BINARY
#######################################################################################################################
New-Item -ItemType Directory -Force -Path "$HOME\Apps\Scoop\Local","$HOME\Apps\Scoop\Global","$HOME\Apps\Scoop\Cache"
Invoke-RestMethod -Verbose 'https://raw.githubusercontent.com/scoopinstaller/install/master/install.ps1' -OutFile "${HOME}\Desktop\scoop-installer.ps1"
& "${HOME}\Desktop\scoop-installer.ps1" -ScoopDir "${HOME}\Apps\Scoop\Local" -ScoopGlobalDir "${HOME}\Apps\Scoop\Global" -ScoopCacheDir "${HOME}\Apps\Scoop\Cache"
# & "${HOME}\Apps\Scoop\Local\shims\scoop.ps1" checkup

#######################################################################################################################
# INSTALL SCOOP BUCKETS
#######################################################################################################################
scoop bucket add main
scoop bucket add extras
scoop bucket add versions
scoop bucket add games
scoop bucket add nirsoft
scoop bucket add sysinternals
scoop bucket add php
scoop bucket add nerd-fonts
scoop bucket add java
scoop bucket add non-portable
# scoop bucket add excavator
# scoop bucket add tests


#######################################################################################################################
# INSTALL SCOOP PACKAGES
#######################################################################################################################
# essential
scoop install main/7zip
scoop install main/git
scoop install main/dark
scoop install 'main/7zip' 'main/git' 'main/dark' 'versions/innounp-unicode' 'main/sudo' 'main/scoop-search'

# addons
scoop install main/sudo
scoop install main/gsudo
scoop install main/scoop-search

# development
scoop install extra/sublime-text
scoop install extras/alacritty
scoop install extras/vscode
scoop install main/eza
scoop install main/micro
scoop install main/neovim
scoop install main/pwsh
scoop install main/starship
scoop install nerd-fonts/IosevkaTerm-NF-Mono

# tools
scoop install extras/everything
scoop install extras/imageglass
scoop install extras/localsend
scoop install extras/sharex
scoop install extras/smplayer
scoop install main/adb

# tweaks
scoop install extras/winaerotweaker
scoop install extras/windhawk
scoop install extras/winutil

# auth
scoop install extras/bitwarden
scoop install extras/ente-auth

# browsers
scoop install extras/brave
scoop install extras/firefox
scoop install extras/google-chrome
scoop install extras/vivaldi

# internet
scoop install extras/discord
scoop install extras/firefox-pwa
scoop install extras/qbittorrent
scoop install extras/telegram

# games
scoop install games/epic-games-launcher
scoop install games/mgba
scoop install games/ps3-system-software
scoop install games/rpcs3
scoop install games/steam
scoop install games/goggalaxy
