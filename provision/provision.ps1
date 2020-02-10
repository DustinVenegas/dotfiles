param(
    [string]$dotfilesPath = (Resolve-Path "$PSScriptRoot\.."),
    [switch]$chocoInstallCore
)

Write-Host "Provisiong against dotfiles located at $dotfilesPath"

function Test-Application {
    <#
    .SYNOPSIS
    Test if the full application name exists in the current environment

    .DESCRIPTION
    Test if any applications available through Get-Command match the parameter exactly

    .PARAMETER $name
    The full name of the application to test

    .RETURNS
    A boolean if the application exists

    .EXAMPLE
    # Returns $false

    Test-Application 'choco'

    .EXAMPLE
    # Returns $true
    Test-Application 'choco.exe'
    #>
    param([string]$name)

    (Get-Command -Type Application | Where-Object { $_.Name -eq $name }) -ne $null
}

# TODO: fsutil any easier?

# Provision Choco
if (Test-Application 'choco.exe' -and $chocoInstallCore) {
    Write-Host "Installing packages"
    # Add personal NuGet packages
    choco source add -n=myget -s https://www.myget.org/F/dustinvenegas/

    # Represents the core packages for running this configuration
    choco install "$dotfilesPath\provision\core-packages.config"
} else {
    Write-Warning "Choco not found. Installing."
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Pin any non-pinned app that's installed and auto-updates NOTE: Choco doesn't support pin on install
$autoUpdates = @('google-chrome-x64','nodejs.install','dropbox','jre8','docker-for-windows','powershell','riot-web');
$pinned = choco pin -r | %{ $_ -Split '\|' | Select-Object -First 1 }
choco list -lo -r | %{
        $_ -Split '\|' | Select-Object -First 1
    } | Where-Object {
        ($autoUpdates -contains $_) -and ($pinned -NotContains $_)
    } | Foreach-Object {
        choco pin add -n="$_" -r
    }

