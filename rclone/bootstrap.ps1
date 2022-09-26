<#
    .Synopsis
        Configure Bash for this Dotfiles configuration
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseCompatibleCommands", "", Justification = "Dotfiles currently supports rclone on Windows.")]
param()
begin {
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest

    $config = Get-DotfilesConfig

    function Install-NSSMService {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseCompatibleCommands",
            "",
            Justification = "Dotfiles currently supports rclone on Windows.",
            Scope = "Function",
            Target = "*")]
        [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
        param(
            [Parameter(Mandatory, Position = 0)]
            [string]$serviceName,
            [Parameter(Mandatory, Position = 1)]
            $commandPath
        )

        $needsUpdate = $true
        $serviceExists = { $null -ne (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) }

        if (-Not (Get-Command 'nssm.exe' -ErrorAction SilentlyContinue)) {
            Write-Error "Could not Set-NSSMService because nssm.exe is missing"
        } else {
            if ($false -eq (&$serviceExists)) {
                if ($PSCmdlet.ShouldProcess('nssm install', $serviceName)) {
                    nssm install $serviceName $commandPath

                    # To keep user-level secrets a secret on multi-user machines.
                    Write-Information "Installed a new service: $serviceName"
                    Write-Information "Edit the service with command: 'nssm edit $serviceName'"
                }
            }

            $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

            switch ($service.Status) {
                'Stopped' {
                    Write-Verbose "Service was stopped. Starting"
                    $service.Start()
                }
                'Started' {
                    Write-Verbose "Service was started."
                    $needsUpdate = $false
                }
                'Paused' {
                    # Services are sometimes paused after too many errors.
                    Write-Warning "Service $serviceName was paused. Check the event logs and manually unpause the service."
                }
                'StartPending' {
                    Write-Warning "Service $serviceName start is pending and not yet completed."
                }
                default {
                    Write-Error "Unexpected status. Service: $serviceName, Status: $($service.Status)"
                }
            }
        }

        [PSCustomObject] @{
            Name        = 'Set-NSSMService'
            NeedsUpdate = $needsUpdate
            Entity      = "$serviceName"
            Properties  = @{
                CommandPath   = $commandPath
                ServiceExists = &$serviceExists
            }
        }
    }
}
process {
    if ($IsWindows) {
        $name = 'rclonerc'

        # Setup system profile
        $exeName = "start-$name.cmd"
        $appdata = "C:\WINDOWS\System32\config\systemprofile\AppData\Local\$name"
        New-Item -Type Directory $appdata -Force | Out-Null

        $passPath = "$appdata\.rclonercp"
        if (-not (Test-Path $passPath)) {
            New-Guid | Select-Object -ExpandProperty Guid > $passPath
        }

        $cmdDest = "$appdata\$exeName"
        $cmdSrc = "$PSScriptRoot\$exeName"
        if (Test-Path $cmdDest) {
            $differences = Compare-Object -ReferenceObject (Get-Content $cmdSrc) -DifferenceObject (Get-Content $cmdDest)
            if ($differences) {
                Write-Host "Differences detected between '$cmdSrc' '$cmdDest'. Differences:"
                $differences | ForEach-Object { "$($PSItem.SideIndicator) $($PSItem.InputObject)" } | Write-Host
                throw "rclonerc differs between src and dest"
            }
        } else {
            Copy-Item $cmdSrc $cmdDest
        }

        # Setup a Windows Service for rclone using the system profile.
        if (-not (Get-Service -Name $name -ErrorAction SilentlyContinue)) {
            nssm install $name $commandPath
        }

        nssm set $name DisplayName 'rclone rc daemon'
        nssm set $name Description 'daemon for running rclone remote control (rc)'
        nssm set $name Start 'SERVICE_AUTO_START'

        nssm set $name AppStdout $appdata\service.log
        nssm set $name AppStderr $appdata\service.log
        nssm set $name AppStdoutCreationDisposition 4
        nssm set $name AppStderrCreationDisposition 4
        nssm set $name AppRotateFiles 1
        nssm set $name AppRotateOnline 0
        nssm set $name AppRotateSeconds 86400
        nssm set $name AppRotateBytes 1048576
    } else {
        Write-Warning 'rclone-gdrive not setup because the OS/platform platform is unrecognized.'
    }
}
