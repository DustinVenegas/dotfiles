<#
    .Synopsis
        Configure PowerShell Core for this Dotfiles repository.
#>
[CmdletBinding()]
#Requires -RunAsAdministrator
#Requires -Version 5
param()
begin {
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest

    # PowerShell uses XDG specification on Unix and Darwin OS-Platforms and 'Documents' on Windows.
    $ccp = '.config/powershell'
    if (Test-OSPlatform -Include 'Windows') {
        $ccp = 'Documents/PowerShell'
    }

    $config = Get-DotfilesConfig

    $ModuleRepository = 'PSGallery'
    $ModuleScope = 'CurrentUser'

    $cuahProfileDirectory = Join-Path -Path $HOME -ChildPath $ccp

    $modulesToManage = @('posh-git', 'PSFzf', 'PSScriptAnalyzer', 'PSReadLine')
    $modulesToInstall = $modulesToManage | Where-Object {
        $null -eq (Get-Module -Name $PSItem -ListAvailable -ErrorAction 'Continue')
    }
}
process {
    Install-Packages $PSScriptRoot

    # Use Current User All Hosts (CUAH) profile directory
    New-SymbolicLink -Path $cuahProfileDirectory -Value $(Resolve-Path $PSScriptRoot)
    Set-JsonValue -Path 'local.dotfiles.json' -InputObject @{ dotfilesLocation = "$($config.Path)" }

    foreach ($m in $modulesToInstall) {
        pwsh -NoLogo -Command "Install-Module -Name $m -Repository $ModuleRepository -Scope $ModuleScope"
    }

    pwsh -NoLogo -Command "Update-Help -ErrorAction SilentlyContinue"
}
