<#
    .Synopsis
        Configure vim for this Dotfiles configuration
    .Description
        Bootstraps the vim portion of the Dotfiles repository
#>
#Requires -Version 5
#Requires -RunAsAdministrator
[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
param()
begin
{
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest

    $vimPath = (Join-Path -Path $HOME -ChildPath '.vim')
    $Config = Get-DotfilesConfig

    $optWhatif = $true
    if ($PSCmdlet.ShouldProcess("Without Option: -whatif ")) {
        $optWhatif = $false
    }
}
Process
{
    Install-Packages $PSScriptRoot -whatif:$optWhatIf

    New-SymbolicLink `
        -Path $vimPath `
        -Value $PSScriptRoot `
        -whatif:$optWhatIf

    Write-Host "Config is $config"
    if ($Config.IsWindows) {
        # Use the dotfiles symlinked configuration at '~/.vim/'
        # instead of the default location (~/vimfiles) on Windows.
        $vimrcWindows = Join-Path $PSScriptRoot '.vimrc.windows'
        New-SymbolicLink `
            -Path $(Join-Path $HOME '_vimrc') `
            -Value $vimrcWindows `
            -whatif:$optWhatIf
    }

    # Blindly update plugins in vim.
    if (-Not $optWhatIf) {
        vim +PlugInstall +qall
    }
    [PSCustomObject] @{
        Name = 'Update-VimPlug'
        NeedsUpdate = $true
        Entity = "vim"
        Properties = @{}
    }
}
