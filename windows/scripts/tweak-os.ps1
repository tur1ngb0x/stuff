function RegNew {
    param([Parameter(Mandatory)] [string] $Path)
    New-Item -Path $Path -Force | Out-Null
}

function RegDel {
    param(
        [Parameter(Mandatory)]
        [string] $Path
    )

    if (-not (Test-Path -Path $Path)) {
        return
    }

    Remove-Item -Path $Path -Recurse -Force
}

function RegQuery {
    param(
        [Parameter(Mandatory)]
        [string] $Path,

        [Parameter(Mandatory)]
        [string] $Name
    )

    if (-not (Test-Path -Path $Path)) {
        throw "Registry key not found: '$Path'."
    }

    try {
        $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop

        [pscustomobject]@{
            Path         = $Path
            Name         = $Name
            PropertyType = (Get-Item -Path $Path).GetValueKind($Name)
            Value        = $item.$Name
        }
    }
    catch {
        throw "Registry value '$Name' does not exist under '$Path'."
    }
}
function RegAdd {
    param(
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [ValidateSet("String", "ExpandString", "Binary", "DWord", "MultiString", "QWord")] [string] $PropertyType,
        [Parameter(Mandatory)] $Value
    )
    if (-not (Test-Path $Path)) { RegNew $Path }
    New-ItemProperty $Path -Name $Name -PropertyType $PropertyType -Value $Value -Force | Out-Null
}

function check-admin {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Please run this script as Administrator. Exiting..."
        exit
    }
}

function tweak-datetime {
    # set time servers
    w32tm.exe /config /manualpeerlist:"time.google.com time.cloudflare.com time.nist.gov time.windows.com time.aws.com" /syncfromflags:manual /update

    # set timezone
    tzutil.exe /s "India Standard Time"

    # synchronize time
    w32tm.exe /resync /force

    # verify configuration
    w32tm.exe /query /peers
    w32tm.exe /query /status
    tzutil.exe /g

    # stop service
    # net.exe stop w32time

    # start service
    # net.exe start w32time
}

function tweak-power {
    # restore default power plans
    powercfg.exe /restoredefaultschemes

    # disable hibernation
    powercfg.exe /hibernate off

    # disable modern standby
    RegAdd 'HKLM:\System\CurrentControlSet\Control\Power' 'PlatformAoAcOverride' DWord 0

    # disable background applications
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' 'GlobalUserDisabled' DWord 1

    # activate balanced power plan
    powercfg.exe /setactive SCHEME_BALANCED

    # disable display timeout
    powercfg.exe /setacvalueindex SCHEME_BALANCED SUB_VIDEO VIDEOIDLE 0
    powercfg.exe /change monitor-timeout-ac 0

    # disable sleep timeout
    powercfg.exe /setacvalueindex SCHEME_BALANCED SUB_SLEEP STANDBYIDLE 0
    powercfg.exe /change standby-timeout-ac 0

    # disable hibernate timeout
    powercfg.exe /change hibernate-timeout-ac 0

    # disable disk timeout
    powercfg.exe /change disk-timeout-ac 0
}

function tweak-explorer {
    # enable classic context menus
    RegNew 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'

    # open File Explorer to This PC
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'LaunchTo' DWord 1

    # show file extensions
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'HideFileExt' DWord 0

    # show hidden files
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Hidden' DWord 1

    # enable compact mode
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'UseCompactMode' DWord 1

    # enable dark mode
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'AppsUseLightTheme' DWord 0
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'SystemUsesLightTheme' DWord 0

    # disable search box web suggestions
    RegAdd 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' DWord 1
    
    # show full path in title bar
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState' 'FullPath' DWord 1
    
    # disable recently used files
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' 'ShowRecent' DWord 0
    
    # disable frequently used folders
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' 'ShowFrequent' DWord 0
    
    # disable sync provider notifications
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowSyncProviderNotifications' DWord 0

    # reset folder view discovery
    RegDel 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags'
    RegNew 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell'
    RegAdd 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell' 'FolderType' String 'NotSpecified'
}

function tweak-taskbar {
    # left-align taskbar
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarAl' DWord 0

    # hide widgets
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarDa' DWord 0

    # hide task view
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowTaskViewButton' DWord 0

    # hide search
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'SearchboxTaskbarMode' DWord 0

    # hide copilot
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowCopilotButton' DWord 0
    
    # show seconds in system tray clock
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowSecondsInSystemClock' DWord 1
}

function tweak-startmenu {
    # more pins, fewer recommendations
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_Layout' DWord 1

    # disable recommendations
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_IrisRecommendations' DWord 0

    # open to all pinned apps
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Start' 'ShowAllPinsList' DWord 1

    # disable recently opened items
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_TrackDocs' DWord 0
    
    # disable account notifications
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Start' 'ShowAccountNotifications' DWord 0
}

function tweak-performance {
    # disable window animations
    RegAdd 'HKCU:\Control Panel\Desktop\WindowMetrics' 'MinAnimate' String '0'

    # disable startup delay
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize' 'StartupDelayInMSec' DWord 0

    # disable transparency
    RegAdd 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'EnableTransparency' DWord 0
}

function tweak-mouse {
    # disable enhanced pointer precision
    RegAdd 'HKCU:\Control Panel\Mouse' 'MouseSpeed' String '0'
    RegAdd 'HKCU:\Control Panel\Mouse' 'MouseThreshold1' String '0'
    RegAdd 'HKCU:\Control Panel\Mouse' 'MouseThreshold2' String '0'

    # pointer speed (1-20, default 10)
    RegAdd 'HKCU:\Control Panel\Mouse' 'MouseSensitivity' String '10'
}

function tweak-system {
    # enable developer mode
    RegAdd 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' 'AllowDevelopmentWithoutDevLicense' DWord 1
    RegAdd 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' 'AllowAllTrustedApps' DWord 1

    # enable sudo
    RegAdd 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Sudo' 'Enabled' DWord 3

    # enable long path support
    RegAdd 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' 'LongPathsEnabled' DWord 1

    # enable verbose status messages
    RegAdd 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' 'VerboseStatus' DWord 1

    # set windows terminal as default
    RegAdd 'HKCU:\Console\%%Startup' 'DelegationConsole' String '{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}'
    RegAdd 'HKCU:\Console\%%Startup' 'DelegationTerminal' String '{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}'

    # set maximum wallpaper quality
    RegAdd 'HKCU:\Control Panel\Desktop' 'JPEGImportQuality' DWord 100

    # add Windows Defender exclusion
    Add-MpPreference -ExclusionPath "$HOME\src"

    # rename computer
    Rename-Computer -NewName 'windows' -Force
}

function tweak-updates {
    # disable automatic updates
    RegAdd 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'NoAutoUpdate' DWord 1

    # disable automatic restart after updates
    RegAdd 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'NoAutoRebootWithLoggedOnUsers' DWord 1

    # notify before download and install
    RegAdd 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'AUOptions' DWord 2

    # exclude driver updates
    RegAdd 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'ExcludeWUDriversInQualityUpdate' DWord 1

    # disable optional updates
    RegAdd 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'SetAllowOptionalContent' DWord 1

    RegAdd 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'AllowOptionalContent' DWord 2

    # disable preview builds
    RegAdd 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'ManagePreviewBuilds' DWord 0

    # disable delivery optimization
    RegAdd 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' 'DODownloadMode' DWord 0

    # defer feature updates by 30 days
    RegAdd 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'DeferFeatureUpdates' DWord 1
    RegAdd 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'DeferFeatureUpdatesPeriodInDays' DWord 30

    # defer quality updates by 30 days
    RegAdd 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'DeferQualityUpdates' DWord 1
    RegAdd 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'DeferQualityUpdatesPeriodInDays' DWord 30
}

function tweak-disk {
    # enable Compact OS
    compact.exe /CompactOS:Query
    compact.exe /CompactOS:Always

    # retrim SSD
    Optimize-Volume -DriveLetter C -ReTrim -Verbose
}

function confirm-reboot {
    while ($true) {
        $response = (Read-Host "Some changes require a reboot. Restart now? (yes/no)").Trim().ToLowerInvariant()

        switch ($response) {
            'yes' { Restart-Computer -Force; return }
            'no'  { Write-Host "Restart skipped. Please restart the computer later for all changes to take effect."; return }
            default { Write-Host "Invalid response. Enter 'yes' or 'no'." }
        }
    }
}
function Main {
    # verify
    check-admin

    # mandatory
    tweak-system
    tweak-datetime
    tweak-updates
    tweak-power

    # optional
    tweak-explorer
    tweak-taskbar
    tweak-startmenu
    tweak-performance
    tweak-mouse
    tweak-disk

    # restart
    confirm-reboot
}

