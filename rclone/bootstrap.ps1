<#
    .Synopsis
    Configure Bash for this Dotfiles configuration
    .Description
    Bootstraps the Bash portion of the Dotfiles repository
#>
#Requires -RunAsAdministrator
#Requires -Version 5
[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
param()
begin {
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest

    $optWhatif = $true
    if ($PSCmdlet.ShouldProcess("Running Without Option: -whatif ")) {
        $optWhatif = $false
    }

    function Install-NSSMService {
        [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
        param(
            [Parameter(Mandatory, Position = 0)]
            [string]$serviceName,
            [Parameter(Mandatory, Position = 1)]
            $commandPath
        )

        $needsUpdate = $true
        $serviceExists = {$null -ne (Get-Service -Name $serviceName -ErrorAction SilentlyContinue)}

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
                default {
                    Write-Error "Unexpected status. Service: $serviceName, Status: $($service.Status)"
                }
            }
        }

        [PSCustomObject] @{
            Name = 'Set-NSSMService'
            NeedsUpdate = $needsUpdate
            Entity = "$serviceName"
            Properties = @{
                CommandPath = $commandPath
                ServiceExists = &$serviceExists
            }
        }
    }
}
process {
    Install-Packages $PSScriptRoot -whatif:$optWhatIf

    # Open rclone settings dialog: nssm edit rclone-gdrive
    Install-NSSMService -ServiceName 'rclone-gdrive' -CommandPath (Join-Path -Path $PSScriptRoot -ChildPath 'mount-gdrive.cmd') -whatif:$optWhatIf
}
