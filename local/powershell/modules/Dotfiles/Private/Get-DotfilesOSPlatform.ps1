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
            if (Get-Variable -Name 'IsMacOS' -ErrorAction SilentlyContinue -ValueOnly) {
                # IsMacOS is included with PowerShell 6+
                $simplifiedRunningOS = 'Darwin'
            } elseif (Get-Command -Name 'uname' -ErrorAction SilentlyContinue) {
                # `uname` works on PowerShell 5
                if ((uname -a) -Like 'Darwin*') {
                    $simplifiedRunningOS = 'Darwin'
                }
            }
        }
        default {
            Write-Warning "Could not determine simplified OS from Platform [$platform]. SimplifiedRunningOS is [$simplifiedRunningOS]."
        }
    }

    return $simplifiedRunningOS
}
