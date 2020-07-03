<#
    .Synopsis
    Configure Markdownlint for this Dotfiles configuration
    .Description
    Bootstraps the Markdownlint portion of the Dotfiles repository
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
    New-SymbolicLink `
        -Path $(Join-Path -Path $HOME -ChildPath '.markdownlintrc') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'markdownlint.json') `
        -whatif:$optWhatIf
}
