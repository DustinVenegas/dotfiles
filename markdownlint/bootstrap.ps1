<#
    .Synopsis
        Configures Markdownlint for this Dotfiles repository.
#>
[CmdletBinding()]
#Requires -Version 5
param()
begin {
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest
}
process {
    New-SymbolicLink `
        -Path $(Join-Path -Path $HOME -ChildPath '.markdownlintrc') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'markdownlint.json')
}
