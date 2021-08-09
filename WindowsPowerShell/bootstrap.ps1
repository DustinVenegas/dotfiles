<#
    .Synopsis
        Configure Windows PowerShell for a Dotfiles configuration
#>
[CmdletBinding()]
#Requires -Version 5
param()
begin {
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest

    function Set-PSRepositoryToTrusted {
        [CmdletBinding()]
        param (
            [string]$Name
        )
        process {
            # If the policy is not already trusted.
            if ((Get-PSRepository -Name $name).InstallationPolicy -ne 'trusted') {
                Set-PSRepository -Name $name -InstallationPolicy 'Trusted'

                [PSCustomObject]@{
                    Name        = 'Set-PSRepository'
                    NeedsUpdate = $true
                    Entity      = "$name"
                    Properties  = @{
                        InstallationPolicy = 'Trusted'
                    }
                }
            }
        }
    }

    $ModuleRepository = 'PSGallery'
    $ModuleScope = 'CurrentUser'

    $modulesToManage = @('posh-git', 'PSFzf', 'PSScriptAnalyzer')
    $modulesToInstall = $modulesToManage | Where-Object {
        $null -eq (Get-Module -Name $PSItem -ListAvailable -ErrorAction 'Continue')
    }
}
Process {
    if (-Not (Test-OSPlatform 'Windows')) {
        Write-Information "Skipping $($PSScriptRoot) because only Windows is supported."
        return
    }

    New-SymbolicLink `
        -Path $(Join-Path (Join-Path $HOME 'Documents') 'WindowsPowerShell') `
        -Value $PSScriptRoot

    Set-PSRepositoryToTrusted -Name $ModuleRepository

    foreach ($m in $modulesToInstall) {
        Install-Module -Name $m -Repository $ModuleRepository -Scope $ModuleScope
    }
}
