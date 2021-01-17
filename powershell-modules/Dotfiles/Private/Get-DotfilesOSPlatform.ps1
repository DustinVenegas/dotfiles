<#
    .Synopsis
        Get a simplified OS-Platform for the currently running OS and Platform.
    .Description
        Provides a simplified OS-Platform for the currently running OS and
        Platform. May return Windows, Unix, Darwin, or Unspecified.

        Unspecified is returned when simplistic matching fails. Darwin is a
        Unix but is specified as Darwin instead. Dotfiles configurations are
        concerned with MacOS and Unix the OS Platforms.
    .Notes
        Valid simplified OS Platforms are: Windows, Unix, Darwin, or Unspecified.
#>
function Get-DotfilesOSPlatform {
    $simplifiedRunningOS = 'Unspecified'

    $platform = [System.Environment]::OSVersion.Platform.ToString()
    switch -Wildcard ($platform) {
        'Win*' { $simplifiedRunningOS = "Windows" }
        'Unix*' {
            $simplifiedRunningOS = 'Unix'

            # MacOS sets a specific property on OSVersion.OS. The property does not exist on other operating
            if ((Get-Member -InputObject ([System.Environment]::OSVersion) -Name 'OS' -ErrorAction Continue) -and
                ('Darwin' -eq [System.Environment]::OSVersion.OS.ToString())) {
                $simplifiedRunningOS = 'Darwin'
            }
        }
        default {
            Write-Warning "Could not determine simplified OS from Platform [$platform]. SimplifiedRunningOS is [$simplifiedRunningOS]."
        }
    }

    return $simplifiedRunningOS
}
