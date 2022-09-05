#Requires -RunAsAdministrator
#Requires -Modules "Microsoft.PowerShell.Management"

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseCompatibleCommands", "Write-EventLog")]
param()

$logName = DotfilesChocoUpdater
$source = update-chocoall.ps1

function setupEventLog {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseCompatibleCommands", "Get-EventLog")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseCompatibleCommands", "New-EventLog")]
    param()

    if (-not (Get-EventLog -LogName $logName -ErrorAction ContinueSilently)) {
        New-EventLog -LogName $logName -Source $source
        Write-EventLog -LogName $logName -Source $source -EntryType Information -Message "Log created." -EventId 1
    }
}

setupEventLog

Write-EventLog -LogName $logName -Source $source -EntryType Information -Message "Ran install-chocoautupdator.ps1." -EventId 2
