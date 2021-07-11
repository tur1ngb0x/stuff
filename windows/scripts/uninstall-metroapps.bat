@echo off

echo.
echo Right click this file and run it as ADMIN
echo.
echo.
echo Uninstalling all Windows UWP Apps...
pause
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" Get-AppxPackage -allusers | where-object {$_.name -notlike "*store*"} | Remove-AppxPackage
pause

