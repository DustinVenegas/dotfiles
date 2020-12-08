<#
    .Synopsis
        Get a custom configuration for Dotfiles scripts.
    .Description
        Returns a custom object representating common configuration and
        utility values for Dotfiles scripts.
#>
function Get-DotfilesConfig {
    [PSCustomObject]@{
        Path                 = Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath ../../..)
        SimplifiedOSPlatform = Get-DotfilesOSPlatform
        IsWindows            = [System.Environment]::OSVersion.Platform.ToString().StartsWith("Win")
        IsUnix               = [System.Environment]::OSVersion.Platform.ToString().StartsWith("Unix")
        IsMacOS              = [System.Environment]::OSVersion.Platform.ToString().StartsWith("Unix") -and [System.Environment]::OSVersion.OS.ToString().StartsWith("Darwin")
    }
}
