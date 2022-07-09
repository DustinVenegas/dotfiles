<#
    .Synopsis
        Bootstrap VSCode for this Dotfiles repository.
#>
[CmdletBinding()]
#Requires -Version 5
param()
begin {
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
}
process {
    # shfmt for the shell-format extension
    go install mvdan.cc/sh/v3/cmd/shfmt@latest
}
