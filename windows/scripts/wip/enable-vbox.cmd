@echo off

echo ------------------------------------------------------------------------
echo  VIRTUALBOX WILL BE ENABLED.
echo  WSL2 WILL BE DISABLED.
echo ------------------------------------------------------------------------

pause

dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /all /norestart

echo ------------------------------------------------------------------------
echo  RESTARTING MACHINE
echo  CLOSE WINDOW TO SKIP RESTART
echo ------------------------------------------------------------------------

pause

shutdown.exe /f /t 0 /r
