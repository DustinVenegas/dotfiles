$env:EDITOR = 'nvim'
$MaximumHistoryCount = 10000

function promptForPOSHGit {
    # colorStatus: Green if no errors, red if errors
    $colorStatus = if ($? -eq $true) { [ConsoleColor]::DarkCyan } else { [ConsoleColor]::Red }

    # Your non-prompt logic here
    $prompt = Write-Prompt "$([System.Environment]::NewLine)$([char]0x0A7) " -ForegroundColor $colorStatus

    # Conditional bits
    if (Test-Path 'env:\AWS_PROFILE') {
        $prompt += Write-Prompt "$([char]0x2601)$($env:AWS_PROFILE) " -ForegroundColor DarkMagenta
    }

    # Write the prompt.
    $prompt += & $GitPromptScriptBlock

    # Suffix
    $prompt += Write-Prompt "$([System.Environment]::NewLine)"
    $prompt += Write-Prompt "$([DateTime]::now.ToString("HH:mm:ss")) " -ForegroundColor Blue
    $prompt += Write-Prompt "$((Get-History -Count 1).id + 1)$('>' * ($nestedPromptLevel))" -ForegroundColor DarkGray
    if ($prompt) { $prompt } else { " " }
}

function Prompt {
    $prompt = promptForPOSHGit
    if ($prompt) { $prompt } else { " " }
}

if (Test-Path "$HOME/.ripgreprc") {
    $env:RIPGREP_CONFIG_PATH = "$HOME/.ripgreprc"
}

if (Test-Path "$PSScriptRoot/profile.local.ps1") {
    . "$PSScriptRoot/profile.local.ps1"
}

if (Get-Command -SilentlyContinue 'fzf') {
    Write-Verbose "Found fzf executable."

    if (Get-Module -ListAvailable -Name 'psfzf') {
        Write-Verbose "Found psfzf PowerShell Module."

        Write-Information "Enabling PSFzf"

        # Rebind Ctrl+t, "swap characters", in PSReadLine to Ctrl+t in PSFzf, Fuzzy-Find Current Provider Path.
        Remove-PSReadlineKeyHandler 'Ctrl+t'

        # Rebind Ctrl+r, "reverse search", in PSReadLine to Ctrl+r in PSFzf, Fuzzy-Find History in Reverse.
        Remove-PSReadlineKeyHandler 'Ctrl+r'

        Import-Module PSFzf
    }
}
