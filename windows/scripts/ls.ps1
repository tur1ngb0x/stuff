function lss {
    [CmdletBinding()]
    param(
        [switch]$NoColor
    )

    $supportsAnsi =
        -not $NoColor -and
        $PSVersionTable.PSVersion.Major -ge 7 -and
        $Host.UI.SupportsVirtualTerminal -and
        ($env:WT_SESSION -or -not $IsWindows)

    $culture = [System.Globalization.CultureInfo]::InvariantCulture

    # Executable extensions (safe)
    $exeExt = @()
    if ($env:PATHEXT) {
        $exeExt = $env:PATHEXT.Split(';') |
            Where-Object { $_ } |
            ForEach-Object { $_.ToLowerInvariant() }
    }

    function Colorize($text, $colorCode) {
        if ($supportsAnsi) {
            return "`e[$colorCode" + "m$text`e[0m"
        }
        return $text
    }

    function SafeTime($item) {
        try {
            return $item.LastWriteTime.ToString(
                'yyyyMMdd-ddd-HHmmss',
                $culture
            )
        }
        catch {
            return '????????-???-??????'
        }
    }

    $items = Get-ChildItem -Force @args -ErrorAction SilentlyContinue

    if (-not $items) { return }

    $useAutosize = $items.Count -le 1000

    $display = $items |
        Sort-Object { -not $_.PSIsContainer }, Name |
        Select-Object `
            @{ Name = 'Modified'; Expression = { SafeTime $_ } },
            @{ Name = 'Items'; Expression = {
                $name = $_.Name -replace "`e", ''  # sanitize ANSI injection

                if ($_.LinkTarget) {
                    Colorize "$name -> $($_.LinkTarget)" '36'  # symlink → cyan
                }
                elseif ($_.PSIsContainer) {
                    Colorize $name '33'  # directory → yellow
                }
                elseif ($exeExt -contains $_.Extension.ToLowerInvariant()) {
                    Colorize $name '32'  # executable → green
                }
                else {
                    Colorize $name '34'  # file → blue
                }
            }}

    if ($useAutosize) {
        $display | Format-Table -AutoSize
    }
    else {
        $display | Format-Table
    }
}
