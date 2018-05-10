<#
    .Synopsis
        Configure Neovim for this Dotfiles configuration

    .Description
        Bootstraps the Neovim portion of the Dotfiles repository

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
        The nvim/ directory is Symlinked over the Neovim user folder.
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
}
Process
{
    # Ensures $DOTFILES_BASE/git
    #    $HOME/.gitconfig -> $dotfiles/git/gitconfig
    #    $HOME/.gitconfig_os -> $dotfiles/git/gitconfig_os_windows
    #    $HOME/.gitignore -> $dotfiles/git/gitignore
    #    $HOME/.gitattributes -> $dotfiles/git/gitattributes
    $symlinks = @{
        (Join-Path -Path $env:LOCALAPPDATA -ChildPath 'nvim') = $PSScriptRoot;
    }

    if ($uninstall)
    {
        # Delete the symlinks that exist
        $symlinks.Keys | Where-Object { Test-DotfilesSymlink -Path $_ -Target $symlinks[$_] } | Foreach-Object { $_.Delete() }
    }
    else
    {
        # Create symlinks
        $symlinks.Keys | %{ Set-DotfilesSymbolicLink -Path $_ -Target $symlinks[$_] -ErrorAction Stop }
    }
}
