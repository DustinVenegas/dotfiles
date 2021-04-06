<#
    .Synopsis
        Configure Windows Terminal for a Dotfiles configuration
#>
[CmdletBinding()]
#Requires -Version 5
param()
begin {
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest

    $wtLocalStatePath = "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\"
}
Process {
    if (-Not (Test-OSPlatform 'Windows')) {
        Write-Information "Skipping $($PSScriptRoot) because only Windows supported. OS/Platform is $($config.SimplifiedOSPlatform)."
        return
    }

    New-SymbolicLink `
        -Path $(Join-Path -Path $wtLocalStatePath -ChildPath 'settings.json') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'settings.json')

    New-SymbolicLink `
        -Path $(Join-Path -Path $wtLocalStatePath -ChildPath 'cmd.png') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'cmd.png')

    New-SymbolicLink `
        -Path $(Join-Path -Path $wtLocalStatePath -ChildPath 'powershell.png') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'powershell.png')

    New-SymbolicLink `
        -Path $(Join-Path -Path $wtLocalStatePath -ChildPath 'powershell-core.png') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'powershell-core.png')

    New-SymbolicLink `
        -Path $(Join-Path -Path $wtLocalStatePath -ChildPath 'ubuntu.png') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'ubuntu.png')
}
