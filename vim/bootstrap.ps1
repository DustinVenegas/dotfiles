<#
    .Synopsis
        Configure vim for this Dotfiles repository.
#>
[CmdletBinding()]
#Requires -Version 5
param()
begin {
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest

    $vimrcFilename = '.vimrc'
    if (Test-OSPlatform -Include 'Windows') {
        $vimrcFilename = '_vimrc'
    }
}
process {
    New-SymbolicLink -Path $(Join-Path -Path $HOME -ChildPath '.vim') -Value $PSScriptRoot
    New-SymbolicLink -Path $(Join-Path -Path $HOME -ChildPath $vimrcFileName) -Value (Join-Path $PSScriptRoot '.vimrc.entrypoint')

    Invoke-Everytime -Name 'Update-VimPlugins' -ScriptBlock {
        # Blindly update plugins in vim.
        vim +PlugInstall +qall
    }
}
