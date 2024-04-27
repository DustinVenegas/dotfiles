$script:keybaseWebhookbotUri = Get-Secret -Vault dotfiles -Name keybaseWebhookUrl -AsPlainText

function emitKeybaseChat {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )

    $params = @{
        Uri  = $keybaseWebhookbotUri
        Body = @{ msg = $Message }
    }

    try {
        Invoke-WebRequest @params
    } catch {
        emitEventLogEntry -Message "Could not emit KeybaseChat! $($_)" -Severity Error
        throw $_
    }
}
