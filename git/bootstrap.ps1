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
    Set-StrictMode -Version latest
    $ErrorActionPreference = "Stop"

    function Test-LinkTarget
    {
        param ($path, $target)

        $resolvedTarget = Resolve-Path $target -ErrorAction SilentlyContinue

        $found = Get-Item $path |
            Where-Object -Property LinkType |
            Where-Object {
                $resolvedLinkTarget = (Resolve-Path $_.Target -ErrorAction SilentlyContinue)
                ($resolvedTarget.Path -eq $resolvedLinkTarget.Path)
            }

        return ($found -ne $null)
    }

    function Set-SymbolicLink
    {
        param
        (
            $path,
            $target
        )

        if (-Not (Test-Path $target)) { Write-Error "Expected target ($target) to exist, but was missing!" }

        if (Test-Path $path)
        {
            if (-Not (Test-LinkTarget $path $target))
            {
                Write-Error "Set-SymbolicLink failed. File already exists at $path, but may not be a symbolic link pointed to $target"
            }
        }
        else
        {
            New-Item -Type SymbolicLink -Path $path -Value $target | Out-Null
        }
    }

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
        $symlinks.Keys | Get-Item -ErrorAction SilentlyContinue | Foreach-Object { $_.Delete() }
    }
    else
    {
        $symlinks.Keys | %{ Set-SymbolicLink -Path $_ -Target $symlinks[$_] }

        # Install or update Posh-Git
        Ensure-PoshGit
    }
}
