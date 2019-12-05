$env:EDITOR = 'nvim'
$MaximumHistoryCount=10000

function Prompt {
    # colorStatus: Green if no errors, red if errors
    $colorStatus = if ($? -eq $true) {[ConsoleColor]::DarkCyan} else { [ConsoleColor]::Red }

    # Your non-prompt logic here
    $prompt = Write-Prompt "`n$([char]0x0A7) " -ForegroundColor $colorStatus

    # Conditional bits
    if (Test-Path 'env:\AWS_PROFILE') {
        $prompt += Write-Prompt "$([char]0x2601)$($env:AWS_PROFILE) " -ForegroundColor DarkMagenta
    }

    # Write the prompt.
    $prompt += & $GitPromptScriptBlock

    # Suffix
    $prompt += "`n"
    $prompt += Write-Prompt "$([DateTime]::now.ToString("HH:mm:ss")) " -ForegroundColor Blue
    $prompt += Write-Prompt "$((Get-History -Count 1).id + 1)$('>' * ($nestedPromptLevel + 1))" -ForegroundColor DarkGray
    if ($prompt) { "$prompt " } else { " " }

    <#
    # our theme
    $colorLocation = [ConsoleColor]::Cyan
    $colorCloud = [ConsoleColor]::Magenta

    Write-Host '{' -NoNewLine -f $colorDelimiter
    Write-Host "$(Get-Location)" -NoNewLine -ForegroundColor $colorLocation
    Write-Host '}' -NoNewLine -f $colorDelimiter
    #>
}

if (Test-Path "$HOME/.ripgreprc") {
    $env:RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
}

if (Test-Path "$PSScriptRoot/profile.local.ps1") {
    . "$PSScriptRoot/profile.local.ps1"
}
