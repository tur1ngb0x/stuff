
# set-executionpolicy -executionpolicy bypass -scope localmachine
# powershell "iwr 'https://raw.githubusercontent.com/tur1ngb0x/scripts/main/win-install.ps1' | iex"

$workdir = "$HOME\win-install"
$ProgressPreference = 'SilentlyContinue'
New-Item -Force -ItemType 'directory' -Path "$workdir" | Out-Null
Push-Location "$workdir"
Set-PSDebug -Trace 1

# drivers
Invoke-WebRequest -Uri 'https://github.com/abbodi1406/vcredist/releases/download/v0.78.0/VisualCppRedist_AIO_x86_x64_78.zip' -OutFile driver-vcredist.exe
Invoke-WebRequest -Uri 'https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe' -OutFile driver-directx.exe
Invoke-WebRequest -Uri 'https://downloadmirror.intel.com/795883/gfx_win_101.2127.exe' -OutFile driver-intel.exe
Invoke-WebRequest -Uri 'https://us.download.nvidia.com/Windows/551.76/551.76-notebook-win10-win11-64bit-international-dch-whql.exe' -OutFile driver-nvidia.exe
Invoke-WebRequest -Uri 'https://glenn.delahoy.com/downloads/sdio/SDIO_1.12.20.761.zip' -OutFile driver-sdio.zip

# apps
Invoke-WebRequest -Uri 'https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US' -OutFile app-firefox.exe
Invoke-WebRequest -Uri 'https://7-zip.org/a/7z2301-x64.exe' -OutFile app-7zip.exe
Invoke-WebRequest -Uri 'https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user' -OutFile app-vscode.exe
Invoke-WebRequest -Uri 'https://mirrors.dotsrc.org/vlc/vlc/3.0.20/win64/vlc-3.0.20-win64.exe' -OutFile app-vlc.exe
Invoke-WebRequest -Uri 'https://gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z' -OutFile app-ffmpeg.7z
Invoke-WebRequest -Uri 'https://github.com/winpython/winpython/releases/download/7.1.20240203final/Winpython64-3.12.2.0dot.exe' -OutFile app-python.exe
Invoke-WebRequest -Uri 'https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/PortableGit-2.44.0-64-bit.7z.exe' -OutFile app-git.exe

# games
Invoke-WebRequest -Uri 'https://github.com/mgba-emu/mgba/releases/download/0.10.3/mGBA-0.10.3-win64-installer.exe' -OutFile game-mgba.exe
Invoke-WebRequest -Uri 'https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe' -OutFile game-steam.exe
Invoke-WebRequest -Uri 'https://cloud-mirror.usebottles.com/redistributable/programs/EpicGamesLauncherInstaller.msi' -OutFile game-epic.msi
Invoke-WebRequest -Uri 'https://static3.cdn.ubi.com/orbit/launcher_installer/UbisoftConnectInstaller.exe' -OutFile game-ubisoft.exe
Invoke-WebRequest -Uri 'https://origin-a.akamaihd.net/EA-Desktop-Client-Download/installer-releases/EAappInstaller.exe' -OutFile game-ea.exe
Invoke-WebRequest -Uri 'https://webinstallers.gog-statics.com/download/GOG_Galaxy_2.0.exe' -OutFile game-gog.exe

# scripts
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/tur1ngb0x/scripts/main/win-install.ps1' -OutFile script-win-install.ps1
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/tur1ngb0x/scripts/main/win-fix.cmd' -OutFile script-win-fix.cmd
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/tur1ngb0x/scripts/main/win-tweaks.ps1' -OutFile script-win-tweaks.ps1
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/master/MAS/All-In-One-Version/MAS_AIO-CRC32_9AE8AFBA.cmd' -OutFile script-win-mas.cmd
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/WindowsAddict/IDM-Activation-Script/main/IAS.cmd' -OutFile script-win-idm.cmd

Set-PSDebug -Off
Pop-Location
explorer "$workdir"

# $ErrorActionPreference = 'Stop'
# $ProgressPreference = 'Continue'
# Invoke-WebRequest -Uri 'https://t1.daumcdn.net/potplayer/PotPlayer/Version/Latest/PotPlayerSetup64.exe' -OutFile "potplayer.exe"
