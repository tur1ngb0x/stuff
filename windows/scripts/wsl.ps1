param (
    [Parameter(Position = 0)]
    [string]$Command,
    [Parameter(Position = 1)]
    [string]$Arg,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Rest
)

function Show-Usage {
    Write-Host "`e[1;32mUsage`e[0m"
    Write-Host "`e[1;32m-----`e[0m"
    Write-Host "$($PSCommandPath) <Option> [Argument...]"

    @(
        @{ Option = "backup";   Argument = "<Distro>";        Description = "export the distro as tar archive in the current directory" }
        @{ Option = "install";  Argument = "<Distro>";        Description = "install the distro from the internet (not Microsoft Store)" }
        @{ Option = "primary";  Argument = "<Distro>";        Description = "set the default distro for wsl.exe" }
        @{ Option = "remove";   Argument = "<Distro>";        Description = "unregister the distro and delete its filesystem" }
        @{ Option = "run";      Argument = "<Distro>";        Description = "run the distro" }
        @{ Option = "stop";     Argument = "<Distro>";        Description = "stop the distro" }
        @{ Option = "user";     Argument = "<Distro> <User>"; Description = "set the default user for a distro" }
        @{ Option = "list";     Argument = "";                Description = "list available and installed distros" }
        @{ Option = "poweroff"; Argument = "";                Description = "shut down all running distros" }
        @{ Option = "info";     Argument = "";                Description = "show WSL version, status, and running distros" }
    ) | ForEach-Object { [pscustomobject]$_ } | Format-Table Option, Argument, Description -AutoSize
    exit
}

function Get-AvailableDistros {
    Write-Host "`e[1;32mAvailable`e[0m"
    Write-Host "`e[1;32m---------`e[0m"
    wsl.exe --list --online | ForEach-Object { ($_ -split '\s+')[0] } | Where-Object { $_ -ne '' } | Where-Object { $_ -notlike 'OracleLinux_*' } | Select-Object -Skip 3 | Sort-Object
}

function Get-InstalledDistros {
    Write-Host "`e[1;32mInstalled`e[0m"
    Write-Host "`e[1;32m---------`e[0m"
    wsl.exe --list --verbose
}

if (-not $Command) {
    Show-Usage
}

switch ($Command.ToLower()) {

    "primary" {
        if (-not $Arg -or $Rest) { Show-Usage }
        wsl.exe --set-default $Arg
    }

    "backup" {
        if (-not $Arg -or $Rest) { Show-Usage }
        wsl.exe --export $Arg "$Arg-$(Get-Date -Format 'yyyyMMdd-HHmmss').tar"
    }

    "info" {
        if ($Arg) { Show-Usage }
        Write-Host "`e[1;32mVersion`e[0m"
        Write-Host "`e[1;32m-------`e[0m"
        wsl.exe --version
        Write-Host "`e[1;32mStatus`e[0m"
        Write-Host "`e[1;32m------`e[0m"
        wsl.exe --status
        Get-InstalledDistros
    }

    "install" {
        if (-not $Arg -or $Rest) { Show-Usage }
        $Arg = $Arg.ToLowerInvariant()
        wsl.exe --install $Arg --name $Arg --location "C:\Users\user\src\wsl\$Arg" --web-download --no-launch
        Get-InstalledDistros
    }

    "list" {
        if ($Arg) { Show-Usage }
        Get-AvailableDistros
        Get-InstalledDistros
    }

    "run" {
        if (-not $Arg -or $Rest) { Show-Usage }
        wsl.exe -d $Arg
    }

    "poweroff" {
        if ($Arg) { Show-Usage }
        wsl.exe --shutdown
        Get-InstalledDistros
    }

    "stop" {
        if (-not $Arg -or $Rest) { Show-Usage }
        wsl.exe --terminate $Arg
        Get-InstalledDistros
    }

    "remove" {
        if (-not $Arg) { Show-Usage }

        $distros = @($Arg) + $Rest
        foreach ($distro in $distros) { wsl.exe --unregister $distro }

        Get-InstalledDistros
    }

    "user" {
        if (-not $Arg -or -not $Rest -or $Rest.Count -ne 1) { Show-Usage }
        wsl.exe --set-default-user -d $Arg -u $Rest[0]
    }

    default {
        Show-Usage
    }
}
