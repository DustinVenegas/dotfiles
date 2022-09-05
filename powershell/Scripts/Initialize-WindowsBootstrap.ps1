#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Bootstrap Windows
.DESCRIPTION
    Install packages for a terminal environment on Windows.
.EXAMPLE
    ./powershell-scripts/bootstrap-windows.ps1
    # run the bootstrapper directly
#>
param(
    [Switch]$listall,
    [Switch]$listoutdated,
    [String]$packagesConfigPath = "$PSScriptRoot\..\chocolatey-bootstrap-packages.config"
)
begin {
    function errorWhenRunning($apps) {
        $running = @();
        foreach ($p in $apps) {
            if (Get-Process -Name $p -ErrorAction SilentlyContinue) {
                $running += $p
            }
        }
        if ($running.Length -gt 0) {
            throw "I pity the fool trying to bootstrap while running $($running -join ', ')!"
            exit -1
        }
    }

    function readPackages($p) {
        $c = [xml](Get-Content -Path $p)
        foreach ($p in $c.packages.package) {
            $p.id
        }
    }

    function getVersions($packageIDs) {
        foreach ($p in $packageIDs) {
            $pi = choco upgrade $p --noop --limit-output --no-progress
            if ($LASTEXITCODE) {
                throw "choco exited with: $LASTEXITCODE"
            }
            $si = $pi.Split('|')
            $vCurrent = $si[1]
            $vAvailable = $si[2]

            [PSCustomObject]@{
                id        = $p
                current   = $vCurrent
                available = $vAvailable
            }
        }
    }

    function update($packageIDs) {
        foreach ($p in $packageIDs) {
            choco upgrade "$p" --confirm --limit-output --no-progress
            if ($LASTEXITCODE) {
                throw "choco exited with: $LASTEXITCODE"
            }
        }
    }
}
process {
    $packageIDs = readPackages $packagesConfigPath
    if ($listall.ToBool() -or $listoutdated.ToBool()) {
        if ($listoutdated.ToBool()) {
            getVersions $packageIDs | Where-Object { $PSItem.current -ne $PSItem.available }
        } else {
            getVersions $packageIDs
        }
    } else {
        errorWhenRunning $('WindowsTerminal', 'pwsh', 'gsudo')
        update $packageIDs
    }
}
