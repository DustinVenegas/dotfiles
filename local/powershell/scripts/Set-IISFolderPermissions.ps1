#Requires -Module InvokeBuild

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseCompatibleCommands", "Get-Acl")]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseCompatibleCommands", "Set-Acl")]
param()

function Set-IisPremissions {
    param (
        [Parameter(Mandatory = $true)]
        [string]$directory)

    if (-not (Test-Path $directory)) {
        throw "Can't set IIS Premissions on missing directory $directory"
    }

    if ($env:OS -ne 'Windows_NT') {
        throw "Only Microsoft Windows is supported"
    }

    $acl = Get-Acl $directory

    $inherit = [system.security.accesscontrol.InheritanceFlags]'ContainerInherit, ObjectInherit'
    $propagation = [system.security.accesscontrol.PropagationFlags]'None'

    $permission = 'IIS_IUSRS', 'FullControl', $inherit, $propagation, 'Allow'
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
    $acl.SetAccessRule($accessRule)

    $permission = 'NETWORK SERVICE', 'FullControl', $inherit, $propagation, 'Allow'
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
    $acl.SetAccessRule($accessRule)


    $acl | Set-Acl $directory
}

function Test-Port {
    param (
        [string]$Computer,
        [int]$Port)

    $Socket = New-Object Net.Sockets.TcpClient
    try {
        $Socket.Connect($Computer, $Port)
    } catch {}

    if ($Socket.Connected) {
        $true
        $Socket.Close()
    } else {
        $false
    }

    $Socket = $null
}
