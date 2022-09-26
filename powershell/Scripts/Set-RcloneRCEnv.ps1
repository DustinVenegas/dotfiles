<#
.SYNOPSIS
Set environment for rclone rc (remote control)
.DESCRIPTION
Configures PowerShell for executing `rclone rc ...` commands against an instance of rclone rc.
.NOTES
Executing commands to `rclone rc ...` requires an RC_USER and RC_PASS to be set as parameters
on each command or as environment variables.
.EXAMPLE
./Set-RcloneRCEnv.ps1; (rclone rc mount/listmounts | ConvertFrom-Json).mountPoints
# List mountpoints
.EXAMPLE
rclone rc mount/mount 'fs=fastmail:/dustin.venegas.me/files/apps/keepass' "mountPoint=$HOME\KeePass\Fastmail" -o vfs-cache-mode=full -vv
# Mount fastmail
#>
$name = 'rclonerc'
$configDir = "C:\WINDOWS\System32\config\systemprofile\AppData\Local\$name"
$passFile = "$configDir\.rclonercp"

if (-not (Test-Path $passFile)) {
    throw "rclone passfile is required but was missing at: $passfile"
}

# Set the envvars
$env:RCLONE_RC_USER = 'rclone'
$env:RCLONE_RC_PASS = Get-Content $passFile
