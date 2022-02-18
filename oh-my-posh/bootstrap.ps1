<#
    .Synopsis
        Configure oh-my-posh for custom command-line prompts
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
        -Path $(Join-Path -Path $HOME -ChildPath '.dotfiles-prompt.minimal.omp.json') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'dotfiles-prompt.minimal.omp.json')

    New-SymbolicLink `
        -Path $(Join-Path -Path $HOME -ChildPath '.dotfiles-prompt.omp.json') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'dotfiles-prompt.omp.json')
}
