<#
    .Synopsis
        Configure Kitty for this Dotfiles configuration
#>
#Requires -Version 5
[CmdletBinding()]
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

    New-SymbolicLink `
        -Path $(Join-Path -Path $HOME -ChildPath ".config/kitty/kitty.conf") `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'kitty.conf')
}
