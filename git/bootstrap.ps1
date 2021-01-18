<#
    .Synopsis
        Configures Git to use the dotfiles configuration files.
#>
[CmdletBinding()]
#Requires -Version 5
param()
begin {
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest

    $config = Get-DotfilesConfig
    $SimplifiedOSPlatform = $config.SimplifiedOSPlatform.ToLower()
}
process {
    # Create gitconfig_local if it does not exist.
    if (-Not (Test-Path gitconfig_local)) {
        Copy-Item -Path gitconfig_local.template -Destination gitconfig_local | Out-Null
    }

    @{
        $(Join-Path -Path $HOME -ChildPath '.gitattributes')   = $(Join-Path -Path $PSScriptRoot -ChildPath 'gitattributes')
        $(Join-Path -Path $HOME -ChildPath '.gitconfig')       = $(Join-Path -Path $PSScriptRoot -ChildPath 'gitconfig')
        $(Join-Path -Path $HOME -ChildPath '.gitignore')       = $(Join-Path -Path $PSScriptRoot -ChildPath 'gitignore')
        $(Join-Path -Path $HOME -ChildPath '.gitconfig_local') = $(Join-Path -Path $PSScriptRoot -ChildPath 'gitconfig_local')
        $(Join-Path -Path $HOME -ChildPath '.gitconfig_os')    = $(Join-Path -Path $PSScriptRoot -ChildPath "gitconfig_os_$SimplifiedOSPlatform")
    }.GetEnumerator() | ForEach-Object {
        New-SymbolicLink -Path $PSItem.Key -Value $PSItem.Value
    }

    Install-Module -Name 'posh-git' -Scope "CurrentUser" -Confirm
}
