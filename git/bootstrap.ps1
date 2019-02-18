<#
    .Synopsis
        Configure Git for this Dotfiles configuration

    .Description
        Bootstraps the Git portion of the Dotfiles repository

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
        Files from the dotfiles git/ directory are Symlinked into $HOME/.git*

        For example, $HOME/.gitconfig should be symlinked to dotfiles/git/gitconfig
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

    function Ensure-PoshGit
    {
        if ((Get-Module -Name posh-git -ListAvailable) -eq $null)
        {
            Write-Host "Installing posh-git"
            Install-Module -Name 'posh-git' -Scope "CurrentUser" -Confirm
        } else {
            Write-Host "Updating posh-git"
            Update-Module -Name 'posh-git' -Confirm
        }
    }
}
Process
{
    # Ensures $DOTFILES_BASE/git
    #    $HOME/.gitconfig -> $dotfiles/git/gitconfig
    #    $HOME/.gitconfig_os -> $dotfiles/git/gitconfig_os_windows
    #    $HOME/.gitignore -> $dotfiles/git/gitignore
    #    $HOME/.gitattributes -> $dotfiles/git/gitattributes
    $symlinks = @{
        (Join-Path -Path $HOME -ChildPath '.gitconfig') = (Join-Path -Path $PSScriptRoot -ChildPath 'gitconfig');
        (Join-Path -Path $HOME -ChildPath '.gitconfig_os') = (Join-Path -Path $PSScriptRoot -ChildPath 'gitconfig_os_windows');
        (Join-Path -Path $HOME -ChildPath '.gitignore') = (Join-Path -Path $PSScriptRoot -ChildPath 'gitignore');
        (Join-Path -Path $HOME -ChildPath '.gitattributes') = (Join-Path -Path $PSScriptRoot -ChildPath 'gitattributes');
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

        # Template out some os-specific attributes once.
        $gitConfigLocal = (Join-Path -Path $HOME -ChildPath '.gitconfig_local')
        if (-Not (Test-Path -Path $gitConfigLocal)) {
            Write-Host "Writing local git config at $gitConfigLocal"
            Copy-Item -Path (Join-Path $PSScriptRoot -ChildPath 'gitconfig_local.template') -Destination $gitConfigLocal
        }

        # Install or update Posh-Git
        Ensure-PoshGit
    }
}
