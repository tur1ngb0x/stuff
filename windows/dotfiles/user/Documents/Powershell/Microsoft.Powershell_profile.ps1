# Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Bypass -Force

# Get-ExecutionPolicy -List
# Get-PSReadLineKeyHandler
# Get-PSReadLineOption
# Set-PSReadLineOption -PredictionViewStyle ListView
# Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
# Set-PSReadLineKeyHandler -Key Ctrl+Tab -Function Complete
# Remove-Item Alias:* -Force

# Set-PSReadLineOption -PredictionSource None
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

# Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
# Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
# Set-PSReadLineKeyHandler -Key Ctrl+A -Function BeginningOfLine
# Set-PSReadLineKeyHandler -Key Ctrl+E -Function EndOfLine
# Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
# Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
# Set-PSReadLineKeyHandler -Key Ctrl+Backspace -Function BackwardKillWord
# Set-PSReadLineKeyHandler -Key Ctrl+Delete -Function KillWord


# Get-Command -Module Microsoft.WinGet.Client
# Get-Command -Module Microsoft.WinGet.Client -CommandType Cmdlet

$env:PATH = "$HOME\src\scripts\windows\;$env:PATH"
$env:PATH = "$HOME\src\bin\;$env:PATH"

$env:EDITOR = "subl.exe"

function adb-opt         { Get-Date; adb.exe kill-server; adb.exe shell cmd package bg-dexopt-job; Get-Date }
function cpsync          { if ($args.Count -eq 0) { Write-Host "usage: $($MyInvocation.MyCommand.Name) <source> <destination>"; return }; robocopy.exe /V /E /Z /ETA /R:2880 /W:30 $args }
function driver-backup   { if ($args.Count -eq 0) { Write-Host "usage: $($MyInvocation.MyCommand.Name) <path>"; return }; New-Item -ItemType Directory -Path $args[0] -Force; Export-WindowsDriver -Online -Destination $args[0] }
function driver-list     { pnputil.exe /enum-drivers }
function fix-disk        { cleanmgr.exe /verylowdisk /sageset:420 | Out-Null; cleanmgr.exe /verylowdisk /sagerun:420 | Out-Null; defrag.exe c: /optimize /printprogress /verbose }
function fix-os          { dism.exe /online /cleanup-image /restorehealth /norestart && sfc.exe /scannow && dism.exe /online /cleanup-image /startcomponentcleanup /resetbase /norestart }
function history-clear   { Clear-History; Clear-Content (Get-PSReadLineOption).HistorySavePath }
function history-file    { (Get-PSReadLineOption).HistorySavePath }
function history-show    { Get-Content (Get-PSReadLineOption).HistorySavePath | ForEach-Object -Begin { $i = 1 } -Process { "{0,5}: {1}" -f $i++, $_ } }

function power-display   { (Add-Type '[DllImport("user32.dll")]public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name A -Pas)::SendMessage(-1,0x0112,0xF170,2) }
function power-hibernate { shutdown.exe /h /t 0 /f }
function power-lock      { rundll32.exe user32.dll,LockWorkStation }
function power-logoff    { shutdown.exe /l /t 0 /f }
function power-reboot    { shutdown.exe /r /t 0 /f }
function power-shutdown  { shutdown.exe /s /t 0 /f }
function power-sleep     { rundll32.exe powrprof.dll,SetSuspendState 0,1,1 }
function power-uefi      { shutdown.exe /fw /t 0 /f }

function purge-brave     { Remove-Item "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data" -Recurse -Force -Confirm }
function purge-chrome    { Remove-Item "$env:LOCALAPPDATA\Google\Chrome\User Data" -Recurse -Force -Confirm }
function purge-edge      { Remove-Item "$env:LOCALAPPDATA\Microsoft\Edge\User Data" -Recurse -Force -Confirm }
function purge-firefox   { Remove-Item "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles", "$env:APPDATA\Mozilla\Firefox\Profiles" -Recurse -Force -Confirm }

function shell-env       { Get-ChildItem Env: | ForEach-Object { "`$env:$($_.Name)`n$($_.Value)`n" } }
function shell-path      { $env:Path -split ";" }

function today-yyyyMMdd-ddd-HHmmss { (Get-Date).ToString("yyyyMMdd-ddd-HHmmss") }
function today-yyyyMMdd-HHmmss { (Get-Date).ToString("yyyyMMdd-HHmmss") }

function create-shim {
    # 'C:\Users\user\AppData\Local\Microsoft\WinGet\Packages\oleg-shilo.mkshim_Microsoft.Winget.Source_8wekyb3d8bbwe\mkshim.exe' `
    #     C:\Users\user\src\bin\mkshim.exe `
    #     'C:\Users\user\AppData\Local\Microsoft\WinGet\Packages\oleg-shilo.mkshim_Microsoft.Winget.Source_8wekyb3d8bbwe\mkshim.exe'

    if ($args.Count -eq 0) {
        Write-Host "usage : $($MyInvocation.MyCommand.Name) <shim> <source>"
        Write-Host "example : $($MyInvocation.MyCommand.Name) git 'C:\Program Files\Git\cmd\git"
        return
    }
    Remove-Item "${HOME}\src\bin\$($args[0]).exe" -Force -ErrorAction SilentlyContinue
    mkshim.exe "${HOME}\src\bin\$($args[0]).exe" "$($args[1])" -elevate
}

function create-symlink {
    if ($args.Count -eq 0) {
        Write-Host "usage : $($MyInvocation.MyCommand.Name) <symlink> <source>"
        Write-Host "example : $($MyInvocation.MyCommand.Name) git 'C:\Program Files\Git\cmd\git.exe"
        return
    }
    Remove-Item "${HOME}\src\bin\$($args[0])" -Force -ErrorAction SilentlyContinue
    New-Item -ItemType SymbolicLink -Path "${HOME}\src\bin\$($args[0]).exe" -Target "$($args[1])"
}

function winget-list {
    if ($args.Count -ne 0) { Write-Host "usage: $($MyInvocation.MyCommand.Name)"; return }
    #Get-WinGetPackage | Select-Object Name,ID,InstalledVersion,Source
    Get-WinGetPackage | Select-Object Name,ID,InstalledVersion,Source | Sort-Object Source,Name
}

function winget-install {
    if ($args.Count -eq 0) { Write-Host "usage: $($MyInvocation.MyCommand.Name) <package-id>"; return }
    winget.exe install --id "$($args[0])" --exact --source winget --accept-source-agreements --disable-interactivity --silent --accept-package-agreements --force
}

function winget-install {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)][Alias('Id')][string]$PackageId,[switch]$Force)
    begin { if (-not $PackageId -and -not $MyInvocation.ExpectingInput) { Write-Host "usage: $($MyInvocation.MyCommand.Name) <package-id>"; return } }
    process { if ($PackageId -and $PSCmdlet.ShouldProcess($PackageId,'Install WinGet package')) { Install-WinGetPackage -Id $PackageId -Mode Silent -Force:$Force } }
}

function winget-update {
    if ($args.Count -eq 0) { Write-Host "usage: $($MyInvocation.MyCommand.Name) <package-id>"; return }
    winget.exe update --id "$($args[0])" --exact --source winget --accept-source-agreements --disable-interactivity --silent --include-unknown --accept-package-agreements --force
}

function winget-uninstall {
    if ($args.Count -eq 0) { Write-Host "usage: $($MyInvocation.MyCommand.Name) <package-id>"; return }
    winget.exe uninstall --id "$($args[0])" --exact --source winget --accept-source-agreements --disable-interactivity --silent
}

function winget-uninstall {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName)][Alias('Id')][string]$PackageId,[switch]$Force)
    begin { if (-not $PackageId -and -not $MyInvocation.ExpectingInput) { Write-Host "usage: $($MyInvocation.MyCommand.Name) <package-id>"; return } }
    process { if ($PackageId -and $PSCmdlet.ShouldProcess($PackageId,'Uninstall WinGet package')) { Uninstall-WinGetPackage -Id $PackageId -Mode Silent -Force:$Force } }
}

function winget-download {
    if ($args.Count -eq 0) { Write-Host "usage: $($MyInvocation.MyCommand.Name) <package-id>"; return }
    winget.exe download --id "$($args[0])" --exact
}

Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

function search-web {
    if ($args.Count -eq 0) { Write-Host "usage: $($MyInvocation.MyCommand.Name) <search-term>"; return }
    $query = [uri]::EscapeDataString(($args -join ' '))
    Start-Process "https://www.google.com/search?q=$query"
}


function Prompt {
    $local:u = "`e[1m`e[32m${env:USERNAME}`e[0m"
    $local:h = "`e[1m`e[36m${env:COMPUTERNAME}`e[0m"
    $local:w = "`e[1m`e[33m${PWD}`e[0m"
    $local:s = "$"
    return "${local:u}@${local:h} ${local:w}`n${local:s} "

}
