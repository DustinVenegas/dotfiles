<#
    .Synopsis
    Configure Kitty for this Dotfiles configuration
    .Description
    Bootstraps the Kitty portion of the Dotfiles repository
#>
#Requires -Version 5
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
        -Path $(Join-Path -Path $HOME -ChildPath ".config/kitty/kitty.conf") `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'kitty.conf') `
        -whatif:$optWhatIf
}
