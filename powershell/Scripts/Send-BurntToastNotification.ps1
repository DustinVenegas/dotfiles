#Requires -Modules BurntToast

function emitWindowsToast {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )

    try {
        Import-Module BurntToast

        New-BurntToastNotification -Text $Message
    } catch {
        emitEventLogEntry -Message "Could not emit WindowsToast! $($_)" -Severity Error
        throw $_
    }
}
