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
    if ($IsWindows) {
        scoop install shfmt
    } elseif ($IsMacOS) {
        brew install shfmt
    }
}
