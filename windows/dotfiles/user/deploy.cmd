@echo off
setlocal

:: Repository root
set "ROOT=%~dp0"

goto :main

:: Create or replace a symbolic link
:link
if not exist "%~dp2" mkdir "%~dp2"
del "%~2" >nul 2>&1
mklink "%~2" "%ROOT%%~1"
exit /b

:main

:: wsl.exe (.wslconfig)
call :link ".wslconfig" "%USERPROFILE%\.wslconfig"

:: pwsh.exe (PowerShell 7+)
call :link "Documents\Powershell\Microsoft.Powershell_profile.ps1" "%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

:: powershell.exe (Windows PowerShell 5.1)
call :link "Documents\Powershell\Microsoft.Powershell_profile.ps1" "%USERPROFILE%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

exit /b
