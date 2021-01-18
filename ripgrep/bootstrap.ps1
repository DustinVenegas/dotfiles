<#
    .Synopsis
        Configure RipGrep (rg) for this Dotfiles configuration
    .Notes
        ./RipGrep/ripgreprc is Symlinked to $HOME/.ripgreprc.

        Environment varibable RIPGREP_CONFIG_PATH is set to $HOME/.ripgreprc
#>
[CmdletBinding()]
#Requires -Version 5
param()
begin {
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest

    $ripgreprcHomePath = $(Join-Path -Path $HOME -ChildPath '.ripgreprc')
}
process {
    New-SymbolicLink `
        -Path $ripgreprcHomePath `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'ripgreprc')

    Set-UserEnvVar -Name RIPGREP_CONFIG_PATH -Value $ripgreprcHomePath
}
