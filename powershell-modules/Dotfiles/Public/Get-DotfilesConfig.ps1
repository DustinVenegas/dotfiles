<#
    .Synopsis
        Get a custom configuration for Dotfiles scripts.
    .Description
        Returns a custom object representating common configuration and
        utility values for Dotfiles scripts.
#>
function Get-DotfilesConfig {
    $isUnix = ([System.Environment]::OSVersion.Platform.ToString()).StartsWith("Unix")

    [PSCustomObject]@{
        Path                 = Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath ../../..)
        SimplifiedOSPlatform = Get-DotfilesOSPlatform
        IsWindows            = [System.Environment]::OSVersion.Platform.ToString().StartsWith("Win")
        IsUnix               = $isUnix
        IsMacOS              = (
            $isUnix -and
            (Get-Member -InputObject ([System.Environment]::OSVersion) -Name 'OS') -and
            ([System.Environment]::OSVersion.OS.ToString().StartsWith("Darwin"))
        )
    }
}
