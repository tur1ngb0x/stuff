@echo off

echo ------------------------------------------------------------------------
echo  WSL2 WILL BE ENABLED.
echo  VIRTUALBOX WILL BE DISABLED.
echo ------------------------------------------------------------------------

pause

dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

echo ------------------------------------------------------------------------
echo  RESTARTING MACHINE
echo  CLOSE WINDOW TO SKIP RESTART
echo ------------------------------------------------------------------------

pause

shutdown.exe /f /t 0 /r
