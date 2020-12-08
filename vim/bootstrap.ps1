<#
    .Synopsis
        Configure vim for this Dotfiles repository.
#>
#Requires -Version 5
#Requires -RunAsAdministrator
[CmdletBinding()]
param()
begin {
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest
}
process {
    Install-Packages $PSScriptRoot

    New-SymbolicLink -Path $(Join-Path -Path $HOME -ChildPath '.vim') -Value $PSScriptRoot

    if (Test-OSPlatform -Include 'Windows') {
        # Link .vimrc.windows to the default vim config on Windows.
        New-SymbolicLink -Path $(Join-Path $HOME '_vimrc') -Value $(Join-Path $PSScriptRoot '.vimrc.windows')
    }

    Invoke-Everytime -Name 'Update-VimPlugins' -ScriptBlock {
        # Blindly update plugins in vim.
        vim +PlugInstall +qall
    }
}
