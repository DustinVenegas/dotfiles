<#
    .Synopsis
        Configure Bash for this Dotfiles repository.
#>
[CmdletBinding()]
#Requires -Version 5
param()
begin {
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest
}
process {
    if (Test-OSPlatform 'Windows') {
        Write-Information "Skipping $($PSScriptRoot) because Windows is not supported."
        return
    }

    Install-Packages $PSScriptRoot

    New-SymbolicLink `
        -Path $(Join-Path -Path $HOME -ChildPath '.bashrc') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'bashrc')

    New-SymbolicLink `
        -Path $(Join-Path -Path $HOME -ChildPath '.bash_profile') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'bash_profile')
}