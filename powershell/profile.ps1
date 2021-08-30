$env:EDITOR = 'nvim'
$MaximumHistoryCount = 10000

function Prompt {
    # $? is modified by running commands so momento the last result *first*.
    $lastCmdOK = $?
    $lastLastExitCode = $LASTEXITCODE

    #####################
    # vt100 escape codes
    #####################
    # Use reset sparing. Spamming resets may cause rendering issues
    # when term windows are resized.
    $rst = "`e[0m" # Reset style, background, and foreground.

    # Insert line, 2=entire line
    $il  = "`e[2L" # Insert line

    # Foreground color escape codes.
    $fgc = @{
        default     = "`e[039m"

        black       = "`e[030m"
        red         = "`e[031m"
        green       = "`e[032m"
        yellow      = "`e[033m"
        blue        = "`e[034m"
        darkmagenta = "`e[035m"
        darkcyan    = "`e[036m"
        darkgrey    = "`e[037m"
    }

    # Background color escape codes.
    $bgc = @{
        default  = "`e[049m"

        darkcyan = "`e[46m"
    }

    #####################
    # first line
    #####################
    $p = $il

    # Status indicator using the section character '§', 0xA7
    $lastCmdOK_C = 'red'
    if ($lastCmdOK) {
        $lastCmdOK_C = 'darkcyan'
    }
    $p += "$($fgc[$lastCmdOK_C])$([char]0x0A7)$($fgc.default) "

    # Current location
    $cl = $executionContext.SessionState.Path.CurrentLocation.Path
    $mntC = '/mnt/c/'
    switch ($cl) {
        { $_.StartsWith($HOME) } { $cl = $_.Replace("$HOME", '~') }
        { $_.StartsWith($mntC) } { $cl = $_.Replace("$mntC", 'WINDOWS:/') }
    }
    $p += "$($bgc.darkcyan)$($fgc.black)$($cl)$($fgc.default)$($bgc.default)"

    # Git Status via posh-git
    $p += "$(Write-VcsStatus) "

    # End the line with an unstyled character to create a boundry, otherwise
    # resizing a terminal may cause effects to 'leak' until the end of line.
    $p += "$([char]0x2591)"

    #####################
    # second line
    #####################

    # Move the cursor to the second line.
    $p += "$([System.Environment]::NewLine)"

    # Current Time
    $p += "$($fgc.darkcyan)$([DateTime]::now.ToString("HH:mm"))$($fgc.default) "

    # Command number
    $p += "$($fgc.darkgrey)$((Get-History -Count 1).id + 1)$($fgc.default)"

    # Prompt ('>') **AND** nested-prompt (also '>')
    $p += "$($fgc.darkcyan)>$('>' * ($nestedPromptLevel))$($fgc.default) "

    #####################
    # Cleanup
    #####################

    # Reset $LASTEXITCODE so the value is available to the terminal.
    $global:LASTEXITCODE = $lastLastExitCode

    # The final prompt is a single string with terminal escape codes to reduce screen tearing.
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
    if ($env:PSModulePath -split $separator | Where-Object { $_ -EQ $dotfilesPSModules } -EQ $null) {
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

if (Get-Module -Name posh-git -ListAvailable -ErrorAction SilentlyContinue) {
    Import-Module posh-git

    # Remove the '[', ']' around the git status.
    $global:GitPromptSettings.BeforeStatus.Text = ''
    $global:GitPromptSettings.AfterStatus.Text = ''
}
