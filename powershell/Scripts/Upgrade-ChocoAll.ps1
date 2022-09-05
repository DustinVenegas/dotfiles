#Requires -Modules "Microsoft.PowerShell.Management"
#Requires -RunAsAdministrator
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'Write-EventLog')]
param()

$logName = 'DotfilesChocoUpdater'
$source = 'update-chocoall.ps1'

$except = "'microsoft-windows-terminal,powershell-core,gsudo'"

Write-EventLog -LogName $logName -Source $source -EntryType Information -Message 'Running choco update.' -EventId 10

try {
    choco upgrade all -y --except $except --limit-output --userememberedoptions
} catch {
    Write-EventLog -LogName $logName -Source $source -EntryType Information -Message "Error: $err" -EventId 11
}

Write-EventLog -LogName $logName -Source $source -EntryType Information -Message 'Update complete!' -EventId 12
