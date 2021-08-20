$env:EDITOR = 'nvim'
$MaximumHistoryCount = 10000

$script:colors = @{
    'darkmagenta' = "`e[035m"
    'darkcyan'    = "`e[036m"
    'darkgrey'    = "`e[037m"
    'reset'       = "`e[0m"
    'red'         = "`e[031m"
}

# To prevent prompt tearing, where visual artifacts like newlines visually break a single line prompt into multiple lines,
function Prompt {
    # $? is modified by running commands so momento the last result *first*.
    $lastCmdOK = $?

    # Beginning of the first line.
    $p = [System.Environment]::NewLine

    # Status indicator using the 'section' character 0x0A7
    # TODO: Is it '0xA7' ?
    $lastCmdOKColors = @{
        $true  = $colors.darkcyan
        $false = $colors.red
    }
    $p += "$($lastCmdOKColors[$lastCmdOK])$([char]0x0A7)$($colors.reset) "

    # Current location
    $p += "$($colors.darkgrey)$($executionContext.SessionState.Path.CurrentLocation.Path)$($colors.reset)"

    if (Test-Path 'env:\AWS_PROFILE') {
        $p += " $($colors.darkmagenta)$([char]0x2601)$($env:AWS_PROFILE)$($colors.reset)"
    }

    # Write VCS status using the posh-git PowerShell Module.
    $p += "$($colors.reset)$(Write-VcsStatus)$($colors.reset)"

    # Second Line
    $p += [System.Environment]::NewLine

    $p += "$($colors.darkcyan)$([DateTime]::now.ToString("HH:mm"))$($colors.reset) "
    $p += "$($colors.darkgrey)$((Get-History -Count 1).id + 1)$('>' * ($nestedPromptLevel + 1))$($colors.reset) "

    # Prevent "prompt tearing" by emitting a single string with terminal escape
    # codes instead of using Write-Host.
    return "$p"
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

    foreach ($i in $dotfilesJson | Get-Member -MemberType NoteProperty) {
        $name = $i.Name
        $value = $dotfilesJson.$name
        Write-Verbose "Setting variable '$name' = '$value'"
        Set-Variable -Name $name -Value $value -Scope Script
    }
}

if ($dotfilesLocation -and (Test-Path $dotfilesLocation)) {
    $separator = $([System.IO.Path]::PathSeparator)

    # Setup custom PowerShell Modules path located in the dotfiles folder.
    Write-Verbose 'Located a dotfiles path'
    $dotfilesPSModules = Join-Path $dotfilesLocation 'powershell-modules'
    if ($env:PSModulePath -split $separator | Where-Object { $_ -eq $dotfilesPSModules } -EQ $null) {
        $env:PSModulePath += "$separator$dotfilesPSModules"
    }
}

if (Get-Command -Name 'fzf' -ErrorAction SilentlyContinue) {
    Write-Verbose "Found fzf executable."

    if (Get-Module -ListAvailable -Name 'psfzf') {
        Write-Verbose "Found psfzf PowerShell Module."

        # Rebind Ctrl+t, "swap characters", in PSReadLine to Ctrl+t in PSFzf, Fuzzy-Find Current Provider Path.
        Remove-PSReadLineKeyHandler 'Ctrl+t'

        # Rebind Ctrl+r, "reverse search", in PSReadLine to Ctrl+r in PSFzf, Fuzzy-Find History in Reverse.
        Remove-PSReadLineKeyHandler 'Ctrl+r'

        Import-Module PSFzf
    }
}

if (Get-Module -Name PSReadLine) {
    if (-Not (Get-PSReadLineKeyHandler -Bound | Where-Object { $_.Function -eq 'ViEditVisually' })) {
        if (Get-Command "$($env:EDITOR)") {
            # <C+X><C+E> should open the current command for editing in $env:EDITOR.
            Set-PSReadLineKeyHandler -Chord 'Ctrl+x,Ctrl+e' -Function ViEditVisually
        }
    }
}
