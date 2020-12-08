<#
    .Synopsis
        Bootstrap VSCode for this Dotfiles repository.
#>
[CmdletBinding()]
#Requires -RunAsAdministrator
#Requires -Version 5
param()
begin {
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))

    $extensionsToManage = @(
        'EditorConfig.EditorConfig',
        'vscodevim.vim',
        'Shan.code-settings-sync'
    )

    $installedExtensions = code --list-extensions
    $extensionsToInstall = $extensionsToManage | Where-Object {
        $_ -NotIn $installedExtensions
    }
}
process {
    Install-Packages $PSScriptRoot

    # Install VSCode Extensions
    foreach ($name in $extensionsToInstall) {
        Invoke-Everytime -Name "Install-VSCodeExtension-$name" -ScriptBlock {
            code --install-extension $name
        }
    }
}
