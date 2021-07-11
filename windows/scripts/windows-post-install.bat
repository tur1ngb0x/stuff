@ECHO OFF

ECHO RIGHT CLICK THIS FILE AND RUN AS ADMINISTRATOR
ECHO.
ECHO.
ECHO START THE SCRIPT ?
ECHO.
PAUSE

CLS

ECHO  [*] RENAMING COMPUTER...
powershell.exe Rename-Computer -NewName "starlabs"
ECHO.
ECHO.
ECHO.
ECHO.

ECHO  [*] ENABLING FILE EXTENSIONS...
powershell.exe reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t  REG_DWORD /d 0 /f
ECHO.
ECHO.
ECHO.
ECHO.

ECHO  [*] ENABLING THIS PC VIEW...
powershell.exe reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d 1 /f
ECHO.
ECHO.
ECHO.
ECHO.

ECHO  [*] ENABLING ALL TRAY ICONS...
powershell.exe reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "EnableAutoTray" /t REG_DWORD /d 0 /f
ECHO.
ECHO.
ECHO.
ECHO.

ECHO  [*] ENABLING DARK MODE...
powershell.exe reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d 0 /f
powershell.exe reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d 0 /f
ECHO.
ECHO.
ECHO.
ECHO.

ECHO  [*] NOTIFYING USER TO DOWNLOAD WINDOWS UPDATES...
powershell.exe reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 2 /f
ECHO.
ECHO.
ECHO.
ECHO.

ECHO  [*] DISABLING FAST STARTUP AND HIBERNATION...
powershell.exe powercfg -h off & ECHO The operation completed successfully.
ECHO.
ECHO.
ECHO.
ECHO.

ECHO  [*] INSTALLING CHOCOLATEY PACKAGE MANAGER...
powershell.exe Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
powershell.exe refreshenv
powershell.exe choco install -y 7zip adb autoruns winaero-tweaker everything telegram vlc
ECHO.
ECHO.
ECHO.
ECHO.

ECHO  [*] TRIMMING C DRIVE...
powershell.exe Optimize-Volume -ReTrim -Verbose -DriveLetter C & ECHO The operation completed successfully.
ECHO.
ECHO.
ECHO.
ECHO.


ECHO  [*] EXCLUDING C DRIVE FROM WINDOWS DEFENDER...
powershell.exe Add-MpPreference -ExclusionPath 'C:\' & ECHO The operation completed successfully.
ECHO.
ECHO.
ECHO.
ECHO.

ECHO  [*] ENABLING WINDOWS SUBSYSTEM FOR LINUX...
powershell.exe Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -n
powershell.exe Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -n
powershell.exe rm C:\Users\pd\Desktop\wsl_update_x64.msi
powershell.exe Invoke-WebRequest https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile C:\Users\pd\Desktop\wsl_update_x64.msi & ECHO The operation completed successfully.
ECHO.
ECHO.
ECHO.
ECHO.

PAUSE

EXIT
