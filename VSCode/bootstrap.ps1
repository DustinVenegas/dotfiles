<#
    .Synopsis
        Configure VSCode and necessary modules for Dotfiles
    .Description
        Bootstraps the VSCode portion of the Dotfiles Repository
#>
#Requires -Version 5
#Requires -RunAsAdministrator
[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
param()
begin
{
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest

    function Install-VSCodeExtension {
        [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
        param (
            [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
            [string]$name
        )
        process {
            if ($PSCmdlet.ShouldProcess("Install VSCode Extension: $name")) {
                code --install-extension $name
            }

            [PSCustomObject]@{
                Name = 'Install-VSCodeExtension'
                NeedsUpdate = $true
                Entity = "$name"
                Properties = @{}
            }
        }
    }

    $optWhatif = $true
    if ($PSCmdlet.ShouldProcess("Without Option: -whatif ")) {
        $optWhatif = $false
    }
}
Process
{
    Install-Packages $PSScriptRoot -whatif:$optWhatIf

    # Install VSCode Extensions
    @(
        'EditorConfig.EditorConfig',
        'vscodevim.vim',
        'Shan.code-settings-sync'
    ) | Install-VSCodeExtension -whatif:$optWhatIf
}
