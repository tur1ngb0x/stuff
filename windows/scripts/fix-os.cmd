@echo off

echo ------------------------------------------------------------------------
echo  SAVE YOUR WORK. CLOSE ALL WINDOWS.
echo ------------------------------------------------------------------------

pause

echo ------------------------------------------------------------------------
echo  dism /online /cleanup-image /restorehealth /norestart
echo ------------------------------------------------------------------------
dism /online /cleanup-image /restorehealth /norestart

echo ------------------------------------------------------------------------
echo  sfc /scannow
echo ------------------------------------------------------------------------
sfc /scannow

echo ------------------------------------------------------------------------
echo  dism /online /cleanup-image /startcomponentcleanup /resetbase /norestart
echo ------------------------------------------------------------------------
dism /online /cleanup-image /startcomponentcleanup /resetbase /norestart

echo ------------------------------------------------------------------------
echo  cleanmgr /verylowdisk /sageset:420
echo ------------------------------------------------------------------------
cleanmgr /verylowdisk /sageset:420

echo ------------------------------------------------------------------------
echo  cleanmgr /verylowdisk /sagerun:420
echo ------------------------------------------------------------------------
cleanmgr /verylowdisk /sagerun:420

echo ------------------------------------------------------------------------
echo  defrag c: /optimize /printprogress /verbose
echo ------------------------------------------------------------------------
defrag c: /optimize /printprogress /verbose

echo ------------------------------------------------------------------------
echo  SAVE YOUR WORK. CLOSE ALL WINDOWS.
echo  REBOOT IMMEDIATELY
echo ------------------------------------------------------------------------

pause

exit

:: :: unused commands
:: @echo off
:: echo.
:: @echo on
:: :: disable auto updates
:: reg add "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 2 /f
:: :: write stdout
:: <command> >> %homedrive%%homepath%\Desktop\filename.txt
:: :: scan disk and fix disk
:: chkdsk.exe c: /scan /perf /r
:: chkdsk.exe d: /x /r
:: :: launch disk cleanup
:: cleanmgr /verylowdisk /sageset:420
:: cleanmgr /sageset:420
:: cleanmgr /verylowdisk /sagerun:420
:: :: open logs
:: explorer.exe %windir%\logs\cbs
:: explorer.exe %windir%\logs\dism
:: :: check if dirty bit is set
:: fsutil dirty query c:
:: :: trim ssd
:: powershell.exe optimize-volume -verbose -retrim -driveletter c
