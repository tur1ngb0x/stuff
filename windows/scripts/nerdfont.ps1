#!/usr/bin/env pwsh
# Requires PowerShell 7+

$ErrorActionPreference = 'Stop'

if ($args.Count -ne 1) {

    Write-Host "Usage: nerdfont.ps1 <fontname>"
    Write-Host "Fonts: https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts"
    exit 1
}

$FontName = $args[0]
$FontURL  = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FontName.zip"

$TempZip  = Join-Path ([IO.Path]::GetTempPath()) "$FontName.zip"
$TempDir  = Join-Path ([IO.Path]::GetTempPath()) "$FontName-extracted"

# Desktop destination
$Desktop  = [Environment]::GetFolderPath('Desktop')
$FontDest = Join-Path $Desktop $FontName

# download font zip
Invoke-WebRequest $FontURL -OutFile $TempZip

# create temp font directory
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

# extract font zip to temp font directory
Expand-Archive -Path $TempZip -DestinationPath $TempDir -Force

# create font destination directory on Desktop
New-Item -ItemType Directory -Path $FontDest -Force | Out-Null

# copy only '*NerdFontMono-*.ttf' fonts
Get-ChildItem $TempDir -Filter '*NerdFontMono-*.ttf' -Recurse | ForEach-Object {
    Copy-Item $_.FullName $FontDest -Force
    Write-Host "Copied $($_.Name)"
}

# open font destination directory
explorer.exe $FontDest

# # Cleanup (optional)
# Remove-Item $TempZip -Force
# Remove-Item $TempDir -Recurse -Force


# function nerdfont-list {
#     Add-Type -AssemblyName PresentationCore

#     $FontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'

#     Get-ChildItem $FontDir -Recurse -Filter *.ttf | ForEach-Object {
#         try {
#             $g = New-Object Windows.Media.GlyphTypeface $_.FullName
#             [PSCustomObject]@{
#                 File       = $_.Name
#                 FamilyName = ($g.FamilyNames.Values -join ', ')
#                 FaceName   = ($g.FaceNames.Values -join ', ')
#             }
#         }
#         catch {
#             Write-Warning "Could not read font: $($_.FullName)"
#         }
#     } | Sort-Object FamilyName, FaceName | Format-Table -AutoSize
# }


# & ([scriptblock]::Create((iwr 'https://to.loredo.me/Install-NerdFont.ps1')))