
function check-admin {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) { Write-Host "Please run this script as Administrator. Exiting..."; exit }
    else { Write-Host "Running as Administrator. Proceeding..." }
}

function timezone {
    # stop service
    net.exe stop w32time.exe

    # set time servers
    w32tm.exe /config /manualpeerlist:"time.google.com time.cloudflare.com time.nist.gov time.windows.com time.aws.com" /syncfromflags:manual /update
    
    # set timezone
    tzutil.exe /s "India Standard Time"

    # start service
    net.exe start w32time

    # sync time
    w32tm.exe /resync /force

    # check status
    w32tm.exe /query /peers
    w32tm.exe /query /status
    tzutil.exe /g
}


function power {
    # disable hibernate & fast startup
    powercfg.exe /hibernate off

    # disable modern standby
    New-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Power' -Name 'PlatformAoAcOverride' -PropertyType DWord -Value 0 -Force

    # disable timeout on ac power
    powercfg.exe /change monitor-timeout-ac 0
    powercfg.exe /change standby-timeout-ac 0
    powercfg.exe /change hibernate-timeout-ac 0
    powercfg.exe /change disk-timeout-ac 0
}


function explorer {
    # enable classic context menus
    New-Item -Path 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' -Force

    # open this pc
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'LaunchTo' -PropertyType DWord -Value 1 -Force

    # enable file extensions
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -PropertyType DWord -Value 0 -Force

    # enable hidden files
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden' -PropertyType DWord -Value 1 -Force

    # enable compact ui
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'UseCompactMode' -PropertyType DWord -Value 1 -Force

    # enable dark mode
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'AppsUseLightTheme' -PropertyType DWord -Value 0 -Force
    New-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'SystemUsesLightTheme' -PropertyType DWord -Value 0 -Force

    # disable web search
    New-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' -Name 'DisableSearchBoxSuggestions' -PropertyType DWord -Value 1 -Force

    # disable folder discovery
    Remove-Item -Path 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags' -Recurse -Force
    New-Item -Path 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell' -Force
    New-ItemProperty -Path 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell' -Name 'FolderType' -Value 'NotSpecified' -PropertyType String -Force
}


function system {
    # enable long path support
    New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -PropertyType DWord -Value 1 -Force

    # enable verbose status messages
    New-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'VerboseStatus' -PropertyType DWord -Value 1 -Force

    # enable max wallpaper quality
    New-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'JPEGImportQuality' -PropertyType DWord -Value 100 -Force

    # enable defender exclusion
    Add-MpPreference -ExclusionPath "$HOME\src"

    # change hostname
    Rename-Computer -NewName 'windows' -Force
}


function tasks {
    # enable compact os
    compact.exe /CompactOS:Query
    compact.exe /CompactOS:Always

    # trim ssd
    Optimize-Volume -DriveLetter C -ReTrim -Verbose
}


function shortcuts {
    # common
    New-Item -ItemType Directory -Path "$HOME\Desktop" -Force *> $null
    $desktop = "$HOME\Desktop"
    $shell   = New-Object -ComObject WScript.Shell

    # windows terminal
    function local:lnk_wt {
        Remove-Item "$desktop\Terminal.lnk" -Force *> $null
        $shortcutPath          = Join-Path $desktop 'Terminal.lnk'
        $shortcut              = $shell.CreateShortcut($shortcutPath)
        $exePath                = Join-Path (Get-AppxPackage -Name Microsoft.WindowsTerminal)[-1].InstallLocation 'wt.exe'
        $shortcut.TargetPath   = $exePath
        $shortcut.IconLocation = "$exePath,0"
        $shortcut.Description  = 'Open Windows Terminal'
        $shortcut.Hotkey       = 'CTRL+ALT+T'
        $shortcut.WindowStyle  = 3
        $shortcut.Save()
        Write-Host "Shortcut created at $shortcutPath"
    }

    # wsl ubuntu 24.04
    function local:lnk_ubuntu {
        Remove-Item "$desktop\Ubuntu.lnk" -Force *> $null
        $shortcutPath          = Join-Path $desktop 'Ubuntu.lnk'
        $shortcut              = $shell.CreateShortcut($shortcutPath)
        $exePath               = Join-Path (Get-AppxPackage -Name CanonicalGroupLimited.Ubuntu24.04LTS)[-1].InstallLocation 'ubuntu2404.exe'
        $shortcut.TargetPath   = $exePath
        $shortcut.IconLocation = "$exePath,0"
        $shortcut.Arguments    = ''
        $shortcut.Description  = 'Open Ubuntu'
        $shortcut.Save()
        Write-Host "Shortcut created at $shortcutPath"
    }

    # create shortcuts
    lnk_wt
    lnk_ubuntu
}

function ask-reboot {
    do { $resp = Read-Host "Reboot immediately for changes to take effect. Proceed? (no/yes): " } until ($resp -eq 'yes' -or $resp -eq 'no')
    if ($resp -eq 'yes') { Restart-Computer -Force }
    else { Write-Host "Reboot skipped. Please reboot manually later." }
}



# begin script from here
check-admin
timezone
power
explorer
system
tasks
shortcuts
ask-reboot
