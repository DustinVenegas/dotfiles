function Install-Packages
{
    <#
    .Synopsis
        Installs Dotfiles packages using common package installers.
    .Description
        Use an package manager appropriate for the operating system.
            - Windows: Install Chocolatey packages from 'chocolatey-packages.config'
            - macOS: Install Homebrew packages from 'Brewfile'
            - Ubuntu: Install apt pacakges from 'ubuntu-installs.txt'
    .Parameter Path
        Path where the package definition is located.
    .Example
        Install-Package -Path $pwd
        # Install packages from 'ubuntu-installs.txt', 'chocolate-packages.config', or a 'Brewfile'.
    .Notes

    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param (
        [Parameter(Mandatory, Position = 0)]
        $Path
    )
    begin {
        function Install-ChocolateyPackages {
            param (
                [Parameter(Mandatory, Position=0)]
                $Path
            )
            if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
                Write-Warning "Chocolatey is missing! Uh, that means the packages couldn't be installed. You'll need to look into this."
            }
            else
            {
                $packagesConfig = (Join-Path -Path $Path -ChildPath 'chocolatey-packages.config')
                if (Test-Path -Path $packagesConfig) {
                    Write-Verbose "Deletected a chocolatey-packages.config at $packagesConfig"
                    &choco install $packagesConfig --confirm --limit-output --no-progress | Write-Verbose
                    Write-Verbose "Choco Completed"
                } else {
                    Write-Information "Skipping Chocolatey package installation since a chocolatey-packages.config was detected at $Path."
                }
            }
        }

        function Install-HomebrewPackages {
            param (
                [Parameter(Mandatory, Position=0)]
                $Path
            )
            if (-Not (Get-Command brew -ErrorAction SilentlyContinue)) {
                Write-Warning "Homebrew is missing! Uh, that means that packages were not installed."
            } else {
                Push-Location $Path
                try {
                    &brew bundle
                }
                catch {
                    Write-Error $_
                }
                finally {
                    Pop-Location
                }
            }
        }

        function Install-UbuntuPackages {
            param (
                [Parameter(Mandatory, Position=0)]
                $Path
            )

            @(Get-Content $Path) | Where-Object {$_ -NotMatch '^#.+'} | xargs sudo apt-get install
        }

        function Reset-Path {
            # Refresh the PATH.
            Write-Verbose "Refreshing the PATH variable."
            Write-Debug  "Old Value $($env:PATH)"
            $env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            Write-Debug  "New Value $($env:PATH)"
        }

        $Config = Get-DotfilesConfig
    }
    process {
        $command = {Write-Warning "No Install-Packages command configured. Something went awry."}
        $type = 'Unknown'

        if ($Config.IsWindows) {
            $type = 'Windows'
            $command = {Install-ChocolateyPackages -Path $Path}
        } elseif ($Config.IsMacOS) {
            $type = 'MacOS'
            $command = {Install-HomebrewPackages -Path $Path}
        } elseif ($Config.IsUnix) {
            if ($null -ne (&lsb_release -a '.*Ubuntu.*')) {
                $type = 'Ubuntu'
                $command = {Install-UbuntuPackages -Path $Path}
            }
        }

        Write-Debug "Command: $command"
        if ($PSCmdlet.ShouldProcess("Destination: $Path")) {
            $result = &$command
            Write-Debug "Result was $result"

            Write-Verbose "Updating PATH variable by resetting to the latest values."
            Reset-Path
        }

        [PSCustomObject]@{
            Name = 'Install-Packages'
            NeedsUpdate = $true
            Entity = Resolve-Path -Path $Path -Relative
            Properties = @{
                Type = $type
            }
        }
    }
}
