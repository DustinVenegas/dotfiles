<#
    .Synopsis
        Configure Windows Terminal
    .Description
        Configures Windows Terminal from Dotfiles
#>
#Requires -Version 5
#Requires -RunAsAdministrator
[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
param()
begin
{
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest

    $optWhatif = $true
    if ($PSCmdlet.ShouldProcess("Without Option: -whatif ")) {
        $optWhatif = $false
    }
}
Process
{
    Install-Packages $PSScriptRoot -whatif:$optWhatIf

    $wtLocalStatePath = "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\"

    New-SymbolicLink `
        -Path (Join-Path -Path $wtLocalStatePath -ChildPath 'settings.json') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'settings.json') `
        -whatif:$optWhatIf

    New-SymbolicLink `
        -Path (Join-Path -Path $wtLocalStatePath -ChildPath 'cmd.png') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'cmd.png') `
        -whatif:$optWhatIf

    New-SymbolicLink `
        -Path (Join-Path -Path $wtLocalStatePath -ChildPath 'powershell.png') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'powershell.png') `
        -whatif:$optWhatIf

    New-SymbolicLink `
        -Path (Join-Path -Path $wtLocalStatePath -ChildPath 'powershell-core.png') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'powershell-core.png') `
        -whatif:$optWhatIf

    New-SymbolicLink `
        -Path (Join-Path -Path $wtLocalStatePath -ChildPath 'ubuntu.png') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'ubuntu.png') `
        -whatif:$optWhatIf
}
