<#
    .Synopsis
        Configure Bash for this Dotfiles configuration
    .Description
        Bootstraps the Bash portion of the Dotfiles repository
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
process
{
    Install-Packages $PSScriptRoot -whatif:$optWhatIf

    New-SymbolicLink `
        -Path $(Join-Path -Path $HOME -ChildPath '.bashrc') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'bashrc') `
        -whatif:$optWhatIf

    New-SymbolicLink `
        -Path $(Join-Path -Path $HOME -ChildPath '.bash_profile') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'bash_profile') `
        -whatif:$optWhatIf
}
