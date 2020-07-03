<#
    .Synopsis
        Configure Git for this Dotfiles configuration
    .Description
        Bootstraps the Git portion of the Dotfiles repository
    .Notes
        Files from the dotfiles git/ directory are Symlinked into $HOME/.git*

        For example, $HOME/.gitconfig should be symlinked to dotfiles/git/gitconfig
#>
#Requires -RunAsAdministrator
#Requires -Version 5
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
param()
begin
{
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest

    $OSSpecificGitConfig = 'unspecified'
    switch -Wildcard ([System.Environment]::OSVersion.Platform.ToString()) {
        'Win*' {
            $OSSpecificGitConfig = 'windows'
        }
        'Unix*' {
            $OSSpecificGitConfig = 'unix'
            if ('Darwin' -eq [System.Environment]::OSVersion.OS.ToString()) {
                $OSSpecificGitConfig = 'macos'
            }
        }
    }

    $optWhatif = $true
    if ($PSCmdlet.ShouldProcess("Without Option: -whatif ")) {
        $optWhatif = $false
    }
}
process
{
    Install-Packages $PSScriptRoot -whatif:$optWhatIf

    New-SymbolicLink `
        -Path $(Join-Path -Path $HOME -ChildPath '.gitconfig') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'gitconfig') `
        -whatif:$optWhatIf

    New-SymbolicLink `
        -Path $(Join-Path -Path $HOME -ChildPath '.gitignore') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'gitignore') `
        -whatif:$optWhatIf

    New-SymbolicLink `
        -Path $(Join-Path -Path $HOME -ChildPath '.gitattributes') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'gitattributes') `
        -whatif:$optWhatIf

    New-SymbolicLink `
        -Path $(Join-Path -Path $HOME -ChildPath '.gitconfig_os') `
        -Value $(Join-Path -Path $PSScriptRoot -ChildPath "gitconfig_os_$OSSpecificGitConfig") `
        -whatif:$optWhatIf

    # Create gitconfig_local if it does not exist.
    if (-Not (Test-Path gitconfig_local)) {
        if ($optWhatif) {
            Write-Verbose "Would have copied gitconfig_local.template to gitconfig_local"
        } else {
            Copy-Item -Path gitconfig_local.template -Destination gitconfig_local
        }
    }

    # Symlink gitconfig_local to $HOME/.gitconfig_local
    if (Test-Path gitconfig_local) {
        New-SymbolicLink `
            -Path $(Join-Path -Path $HOME -ChildPath '.gitconfig_local') `
            -Value $(Join-Path -Path $PSScriptRoot -ChildPath 'gitconfig_local') `
            -whatif:$optWhatIf
    }

    Install-Module -Name 'posh-git' -Scope "CurrentUser" -Confirm -whatif:$optWhatIf
}
