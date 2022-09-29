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

    $modulesToManage = @('posh-git', 'PSFzf', 'PSScriptAnalyzer', 'PSReadLine', 'Terminal-Icons', 'PowerShellForGitHub')

    if (Test-OSPlatform -Include @('Unix', 'Darwin')) {
        $modulesToManage += 'Microsoft.PowerShell.UnixCompleters' # PSUnixUtilCompleters
    }

    $modulesToInstall = $modulesToManage | Where-Object {
        $null -eq (Get-Module -Name $PSItem -ListAvailable -ErrorAction 'Continue')
    }

    function Add-WindowsDefenderExclude {
        <#
        .SYNOPSIS
        Sets WindowsDefender to work with PSILoveBackups
        #>
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseCompatibleCommands", "Get-MpPreference")]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseCompatibleCommands", "Add-MpPreference")]
        [CmdletBinding()]
        param($Command)

        if (-not $IsWindows) { return }

        Import-Module -Name ConfigDefender -ErrorAction SilentlyContinue
        if (-not (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Warning 'WindowsDefender ExclusionProcesses requires administrator privileges to set. Skipping.'
            return
        }

        $ep = Get-MpPreference | Select-Object -ExpandProperty ExclusionProcess
        $rp = (Get-Command $Command).Path
        if ((Test-Path $rp) -and ($ep -notcontains $rp)) {
            $ep += $rp

            Write-Verbose "Adding exlucsion $rp to WindowsDefender exclusions: $ep"
            Add-MpPreference -ExclusionProcess $ep
        }
    }
}
process {
    # Use Current User All Hosts (CUAH) profile directory
    New-SymbolicLink -Path $cuahProfileDirectory -Value $(Resolve-Path $PSScriptRoot)

    foreach ($m in $modulesToInstall) {
        pwsh -NoLogo -Command "Install-Module -Name $m -Repository $ModuleRepository -Scope $ModuleScope -Confirm"
    }

    pwsh -NoLogo -Command 'Update-Help -ErrorAction SilentlyContinue'

    Add-WindowsDefenderExclude -Command 'oh-my-posh'
}
