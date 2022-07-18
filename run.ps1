<#
.SYNOPSIS
    Install or update dotfiles
.DESCRIPTION
    Run the bootstrapper for all dotfiles modules.
.EXAMPLE
    PS> ./run.ps1
    Installs or updates dotfiles modules.
#>
#Requires -RunAsAdministrator
param()
begin {
    Import-Module -Name (Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath ./powershell-modules/Dotfiles/Dotfiles.psm1))
    $bootstrapScripts = Get-ChildItem -Include bootstrap.ps1 -Recurse -Depth 1 .
}
process {
    foreach ($script in $bootstrapScripts) {
        # Install system packages
        Install-Packages $script.Directory

        # Bootstrap the component
        Push-Location $script.Directory
        ./bootstrap.ps1
        Pop-Location
    }
}
