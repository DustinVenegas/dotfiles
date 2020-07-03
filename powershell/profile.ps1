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

# Support an optional local.profile.ps1.
$profileLocalPath = Join-Path -Path $PSScriptRoot -ChildPath 'local.profile.ps1'
if (Test-Path "$profileLocalPath") {
    Write-Verbose "Located an optional local.profile.ps1"
    . "$PSScriptRoot/local.profile.ps1"
}

# Support an optional local.dotfiles.json for machine-specific configuration values.
$dotfilesJsonPath = Join-Path -Path $PSScriptRoot -ChildPath 'local.dotfiles.json'
if (Test-Path $dotfilesJsonPath) {
    Write-Verbose 'Located an optional local.dotfiles.json'
    $dotfilesJson = Get-Content -Path $dotfilesJsonPath -Raw | ConvertFrom-Json

    foreach($i in $dotfilesJson | Get-Member -MemberType NoteProperty) {
        $name = $i.Name
        $value = $dotfilesJson.$name
        Write-Verbose "Setting variable '$name' = '$value'"
        Set-Variable -Name $name -Value $value -Scope Script
    }
}

if ($dotfilesLocation -and (Test-Path $dotfilesLocation)) {
    # Setup custom PowerShell Modules path located in the dotfiles folder.
    Write-Verbose 'Located a dotfiles path'
    $dotfilesPSModules = Join-Path $dotfilesLocation 'powershell-modules'
    if ($env:PSModulePath -split ';' | Where-Object {$_ -eq $dotfilesPSModules} -eq $null) {
        $env:PSModulePath += ";$dotfilesPSModules"
    }
}

if (Get-Command -SilentlyContinue 'fzf') {
    Write-Verbose "Found fzf executable."

    if (Get-Module -ListAvailable -Name 'psfzf') {
        Write-Verbose "Found psfzf PowerShell Module."

        # Rebind Ctrl+t, "swap characters", in PSReadLine to Ctrl+t in PSFzf, Fuzzy-Find Current Provider Path.
        Remove-PSReadlineKeyHandler 'Ctrl+t'

        # Rebind Ctrl+r, "reverse search", in PSReadLine to Ctrl+r in PSFzf, Fuzzy-Find History in Reverse.
        Remove-PSReadlineKeyHandler 'Ctrl+r'

        Import-Module PSFzf
    }
}
