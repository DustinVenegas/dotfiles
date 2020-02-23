<#
    .Synopsis
        Configure rclone for this Dotfiles configuration

    .Description
        Bootstraps the rclone portion of the Dotfiles repository

    .Parameter Uninstall
        Removes appropriate installed files outside of the Dotfiles repository.

    .Parameter Confirm
        Approves all prompts

    .Example
        # Run bootstrapper, approving everything
        .\bootstrap.ps1 -Confirm

    .Example
        # Uninstall
        .\bootstrap.ps1 -Uninstall
#>
#Requires -Version 5

$nssm = (Get-Command nssm).Source
$serviceName = 'rclone-gdrive'
$rclone = (Get-Command $PSScriptRoot\mount-gdrive.cmd).Source
& $nssm install $serviceName $rclone $arguments

# To keep user-level secrets a secret on multi-user machines.
Write-Information "Set Log On to run as your personal user account instead of the system account."

# Opens dialoge to modify rclone settings.
& $nssm edit rclone-gdrive