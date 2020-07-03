<#
    .Synopsis
    Configure PowerShell Core for this Dotfiles configuration
    .Description
    Bootstraps the PowerShell Core (pwsh) portion of the Dotfiles repository
#>
#Requires -RunAsAdministrator
#Requires -Version 5
[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
param()
begin
{
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest

    $config = Get-DotfilesConfig

    function cuahProfileDirectory {
        # Current User All Hosts config varies by environment.
        $cuahChildPath = '.config/powershell'
        if ($config.IsWindows) {
            $cuahChildPath = 'Documents/PowerShell'
        }

        Join-Path -Path $HOME -ChildPath $cuahChildPath
    }

    function Update-LocalhostHelpfiles {
        [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
        param ()
        process {
            if ($PSCmdlet.ShouldProcess("Local Cache of PowerShell Helpfiles")) {
                # TODO: Move into some kind of periodic update. This function takes forever.
                Write-Verbose "Running Update-Help"
                Update-Help -ErrorAction SilentlyContinue
            }

            [PSCustomObject]@{
                Name = 'Update-LocalhostHelpfiles'
                NeedsUpdate = $true
                Entity = 'Helpfile Cache'
                Properties = @{
                    Cache = 'Localhost'
                }
            }
        }
    }

    function Set-PSModuleInstallation {
        [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
        param (
            [string]$name,
            [string]$psr = 'PSGallery', # Repository
            [string]$psrs = 'CurrentUser' # Scope
        )
        process {
            $needsUpdate = $false

            if ($null -eq (Get-Module -Name $name -ErrorAction 'Continue')) {
                $needsUpdate = $true
                if ($PSCmdlet.ShouldProcess("Install PowerShell Module: $name")) {
                    Install-Module -Repository $psr -Name $name -Scope $psrs
                }
            }

            [PSCustomObject]@{
                Name = 'Set-PSModuleInstallation'
                NeedsUpdate = $needsUpdate
                Entity = "$name"
                Properties = @{
                    Scope = $psrs
                    Repository = $psr
                    Name = $name
                }
            }
        }
    }

    # TODO: Replace -whatif options with ShouldProcess blocks to a switch in order to simplify.
    $optWhatif = $true
    if ($PSCmdlet.ShouldProcess("turn OFF -whatif option")) {
        $optWhatif = $false
    }
}
process
{
    Install-Packages $PSScriptRoot -whatif:$optWhatIf
    New-SymbolicLink -Path $(cuahProfileDirectory) -Value $(Resolve-Path $PSScriptRoot) -whatif:$optWhatIf
    Set-JsonValue -Path 'local.dotfiles.json' -InputObject @{ dotfilesLocation = "$($config.Path)" } -whatif:$optWhatIf
    Update-LocalhostHelpfiles -whatif:$optWhatIf

    Set-PSModuleInstallation -Name posh-git
    Set-PSModuleInstallation -Name PSFzF
    Set-PSModuleInstallation -Name PSScriptAnalyzer
}
