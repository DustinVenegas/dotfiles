<#
    .Synopsis
        Configure Kitty for this Dotfiles configuration
#>
[CmdletBinding()]
#Requires -Version 5
param()
begin {
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest
}
process {
    if (-Not (Test-OSPlatform -Include 'Unix', 'Darwin')) {
        Write-Information 'Skipping dotfiles configuration because the current platform is not a supported OS/Platform.'
        return
    }

    Install-Packages $PSScriptRoot

    $kittyDir = $(Join-Path -Path $HOME -ChildPath ".config" -AdditionalChildPath 'kitty')
    if (-not (Test-Path $kittyDir)) {
        New-Item -Path $kittyDir -ItemType Directory -Force
    }

    New-SymbolicLink `
        -Path $(Join-Path -Path $kittyDir -ChildPath 'kitty.conf') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'kitty.conf')
}
