<#
    .Synopsis
        Configure RipGrep (rg) for this Dotfiles configuration

    .Description
        Bootstraps the rg portion of the Dotfiles repository

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
        ./RipGrep/ripgreprc is Symlinked to $HOME/.ripgreprc.

        Environment varibable RIPGREP_CONFIG_PATH is set to $HOME/.ripgreprc
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
    # Ensures $DOTFILES_BASE/git
    #    $HOME/.ripgreprc -> $dotfiles/RipGrep/ripgreprc
    $symlinks = @{
        (Join-Path -Path $HOME -ChildPath '.config/powershell') = $PSScriptRoot;
    }

    if ($uninstall)
    {
        # Delete the symlinks that exist
        $symlinks.Keys | Where-Object { Test-DotfilesSymlink -Path $_ -Target $symlinks[$_] } | Foreach-Object { $_.Delete() }
    }
    else
    {
        # Ensure Chocolatey packages are installed
        choco install (Join-Path $PSScriptRoot 'chocolatey-packages.config') -y

        # Create symlinks
        $symlinks.Keys | %{ Set-DotfilesSymbolicLink -Path $_ -Target $symlinks[$_] }

        # Set EDITOR to nvim-qt
        Set-UserEnvVar -Name RIPGREP_CONFIG_PATH -Value $ripgreprcPath
    }
}
