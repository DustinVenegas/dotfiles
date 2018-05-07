<#
    .Synopsis
        Configure ConEmu and necessary modules for Dotfiles

    .Description
        Bootstraps the ConEmu portion of the Dotfiles Repository

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
        Check symlink map for additional information

#>
#Requires -Version 5
#Requires -RunAsAdministrator
[CmdletBinding()]
param(
    [switch]$confirm,
    [switch]$uninstall
)
Begin
{
    $dotfilesModulePath = Resolve-Path (Join-Path $PSScriptRoot ../WindowsPowerShell/Modules-Dotfiles/Dotfiles/Dotfiles.psm1)
    Import-Module -Name $dotfilesModulePath
    Set-StrictMode -Version Latest
    $ErrorActionPreference = "Stop"
}
Process
{
    # Maps: AppData/Roaming/Code/User/* -> $dotfiles/ConEmu/*
    $symlinks = @{
        (Join-Path "$env:APPDATA\" "ConEmu.xml") = (Join-Path $PSScriptRoot "ConEmu.xml");
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
    }
}
