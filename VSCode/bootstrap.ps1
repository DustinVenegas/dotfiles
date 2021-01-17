<#
    .Synopsis
        Bootstrap VSCode for this Dotfiles repository.
#>
[CmdletBinding()]
#Requires -RunAsAdministrator
#Requires -Version 5
param()
begin {
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
}
process {
    Install-Packages $PSScriptRoot
}
