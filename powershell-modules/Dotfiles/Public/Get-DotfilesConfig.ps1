<#
    .Synopsis
        Get a custom configuration for Dotfiles scripts.
    .Description
        Returns a custom object representating common configuration and
        utility values for Dotfiles scripts.
#>
function Get-DotfilesConfig {
    $macDetected = $false
    if (Get-Variable -Name 'IsMacOS' -ErrorAction SilentlyContinue) {
        $macDetected = Get-Variable -Name 'IsMacOS' -ValueOnly
    }

    [PSCustomObject]@{
        Path                 = Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath ../../..)
        SimplifiedOSPlatform = Get-DotfilesOSPlatform
        IsWindows            = [System.Environment]::OSVersion.Platform.ToString().StartsWith("Win")
        IsUnix               = ([System.Environment]::OSVersion.Platform.ToString()).StartsWith("Unix")
        IsMacOS              = $macDetected
    }
}
