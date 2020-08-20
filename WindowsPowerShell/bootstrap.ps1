<#
    .Synopsis
        Sets the Windows PowerShell configuration.
    .Description
        Sets the Windows PowerShell configuration, on Microsoft Windows only.
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
Process {
    Install-Packages $PSScriptRoot -whatif:$optWhatIf

    # Make this folder the root folder for the PowerShell Profile.
    New-SymbolicLink `
        -Path $(Join-Path (Join-path $HOME 'Documents') 'WindowsPowerShell') `
        -Value $PSScriptRoot `
        -whatif:$optWhatIf

    # Trust scripts PSRepository locations. Removes warnings when downloading from these locations.
    @('PSGallery') |
        Where-Object {(Get-PSRepository -Name $_).InstallationPolicy -ne 'trusted'} |
        Foreach-Object {
            if ($PSCmdlet.ShouldProcess("Set InstallationPolicy for PSRepository: $_")) {
                Set-PSRepository -Name $_ -InstallationPolicy 'Trusted'
            }

            [PSCustomObject]@{
                Name = 'Set-PSRepository'
                NeedsUpdate = $true
                Entity = "$_"
                Properties = @{
                    InstallationPolicy = 'Trusted'
                }
            }
        }

    $psr = 'PSGallery' # Repository
    $psrs = 'CurrentUser' # Scope
    @('posh-git','PSFzf','PSScriptAnalyzer') |
        Where-Object {$null -eq (Get-Module -Name $_ -ErrorAction 'Continue')} |
        Foreach-Object {
            if ($PSCmdlet.ShouldProcess("Install PowerShell Module: $_")) {
                Install-Module -Repository $psr -Name $_ -Scope $psrs
            }

            [PSCustomObject]@{
                Name = 'Install-Module'
                NeedsUpdate = $true
                Entity = "$_"
                Properties = @{
                    Scope = $psrs
                    Repository = $psr
                    Name = $_
                }
            }
        }
}
