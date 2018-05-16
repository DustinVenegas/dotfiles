#Requires -Version 5
<#
Creates symbolic links for some dotfiles. Just a proof of concept.
#>

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
}
Process
{
    $ErrorActionPreference = "Stop"

    # Maps: AppData/Roaming/Code/User/* -> $dotfiles/VSCode/*
    $hyperConfigFileName = '.hyper.js'
    $symlinks = @{
        (Join-Path -Path $HOME -ChildPath $hyperConfigFileName) = (Join-Path $PSScriptRoot $hyperConfigFileName);
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
