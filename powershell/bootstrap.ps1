<#
    .Synopsis
        Configure PowerShell Core for this Dotfiles configuration

    .Description
        Bootstraps the PowerShell Core (pwsh) portion of the Dotfiles repository

    .Parameter Uninstall
        Removes appropriate installed files outside of the Dotfiles repository.

    .Parameter Confirm
        Approves all prompts

    .Example
        # Run bootstrapper, approving everything
        .\bootstrap.ps1 -Confirm

    .Example
        # Uninstall
        .\bootstrap.ps1 -Uninstall

    .Notes
        ./powershell is Symlinked to $HOME/.config/powershell
        or $HOME/Documents/PowerShell depending on the OS.
#>
#Requires -Version 5
[CmdletBinding()]
param(
    [switch]$confirm,
    [switch]$uninstall
)
Begin
{
    $dotfilesModulePath = Resolve-Path (Join-Path $PSScriptRoot ../WindowsPowerShell/Modules-Dotfiles/Dotfiles/Dotfiles.psm1)
    Import-Module -Name $dotfilesModulePath
    Set-StrictMode -Version latest
    $ErrorActionPreference = "Stop"

    function Set-UserEnvVar
    {
        param
        (
            $name,
            $value
        )

        $current = [System.Environment]::GetEnvironmentVariable($name, "User")

        if ($current -ne $value)
        {
            Write-Verbose "Setting User Environment variable $name to [$value] from [$current]"
            [Environment]::SetEnvironmentVariable($name, $value, "User")
        }
    }
}
Process
{
    # Current User All Hosts config varies by environment.
    $cuah = '.config/powershell'
    if ($IsWindows) {
        $cuah = 'Documents/PowerShell'
    }

    $symlinks = @{
        (Join-Path -Path $HOME -ChildPath "$cuah") = $PSScriptRoot;
    }

    if ($uninstall)
    {
        # Delete the symlinks that exist
        $symlinks.Keys | Where-Object { Test-DotfilesSymlink -Path $_ -Target $symlinks[$_] } | Foreach-Object { $_.Delete() }
    }
    else
    {
        # Create symlinks
        $symlinks.Keys | %{ Set-DotfilesSymbolicLink -Path $_ -Target $symlinks[$_] }

        # Install Help Files
        Update-Help -ErrorAction SilentlyContinue
    }
}
