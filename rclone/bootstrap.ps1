<#
    .Synopsis
        Configure Bash for this Dotfiles configuration
#>
#Requires -RunAsAdministrator
#Requires -Version 5
[CmdletBinding()]
param()
begin {
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest

    $config = Get-DotfilesConfig

    function Install-NSSMService {
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
    Install-Packages $PSScriptRoot

    switch ($config.SimplifiedOSPlatform) {
        'Windows' {
            # Open rclone settings dialog: nssm edit rclone-gdrive
            Install-NSSMService -ServiceName 'rclone-gdrive' -CommandPath (Join-Path -Path $PSScriptRoot -ChildPath 'mount-gdrive.cmd')
        }
        default {
            Write-Warning 'rclone-gdrive not setup because the OS/platform platform is unrecognized.'
        }
    }
}
