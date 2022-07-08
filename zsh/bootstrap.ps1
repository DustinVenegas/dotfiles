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

    New-SymbolicLink `
        -Path $(Join-Path -Path $env:HOME -ChildPath '.zshrc') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'zshrc')

    $localrc = Join-Path -Path $PSScriptRoot -ChildPath 'local.zshrc'
    if (Test-Path -Path $localrc) {
        New-SymbolicLink `
            -Path $(Join-Path -Path $HOME -ChildPath '.zshrc.local') `
            -Value $localrc
    }
}
