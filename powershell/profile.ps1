$env:EDITOR = 'nvim'
$MaximumHistoryCount = 10000

$dotfilesLocation = (Get-Item $MyInvocation.MyCommand.Source).Directory
$dotfilesLocation | Select-Object -ExpandProperty Target | Set-Variable -Name dotfilesLocation
$dotfilesLocation = Resolve-Path -Path (Join-Path $dotfilesLocation ..)

$dotfilesEnhancedTerm = $false
if ($env:TERM_PROGRAM -eq 'VSCode') { $dotfilesEnhancedTerm = $true } # VSCode
if ($env:WT_SESSION) { $dotfilesEnhancedTerm = $true } # Windows Terminal

# Optional local.profile.ps1 for profile machine-specific profile functions.
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

        Set-PsFzfOption -TabExpansion -GitKeyBindings -EnableAliasFuzzyEdit -EnableAliasFuzzyHistory -EnableAliasFuzzyKillProcess -EnableAliasFuzzySetLocation -EnableAliasFuzzyZLocation -EnableAliasFuzzyGitStatus
    }
}

if (Get-Module -Name PSReadLine) {
    Import-Module PSReadLine
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

if (Get-Command -Name 'oh-my-posh' -ErrorAction SilentlyContinue) {
    $ompDir = Join-Path $dotfilesLocation 'oh-my-posh'

    $variation = '.minimal'
    if ($dotfilesEnhancedTerm) { $variation = '' }

    $ompTheme = Resolve-Path (Join-Path $ompDir "dotfiles-prompt${variation}.omp.json")
    oh-my-posh --init --shell pwsh --config "$ompTheme" | Invoke-Expression

    $v = New-Object System.Version($(oh-my-posh --version))
    if ($dotfilesEnhancedTerm -and ($v.Major -gt 7) -or (($v.Major -eq 7) -and ($v.Minor -ge 20))) {
        # Enables support for PSReadLine PromptText options.
        Enable-PoshLineError
    }

    # oh-my-posh calls Set-PoshContext
    function Set-DotfilesOhMyPoshContext() {
        if ($zlocationEnabled) {
            Update-ZLocation -Path $pwd
        }
    }
    New-Alias -Name 'Set-PoshContext' -Value 'Set-DotfilesOhMyPoshContext' -Scope Global -Force
}

if (($IsLinux -or $IsMacOS) -and (Get-Module -Name Microsoft.PowerShell.UnixCompleters -ListAvailable -ErrorAction SilentlyContinue)) {
    # PSUnixUtilCompleters enables argument completion for Linux binaries. Data is based on shell competions loaded into a zsh/bash.
    Import-Module Microsoft.PowerShell.UnixCompleters

    # 'tab' on a '-' or '--' provides a friendly menu to cycle through arguments.
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}

if ($enhancedTerm) {
    Import-Module -Name Terminal-Icons
}

$zlocationEnabled = $false
if (Get-Module -Name ZLocation -ListAvailable -ErrorAction SilentlyContinue) {
    if (-Not ((Get-Command -Name ZLocationOrigPrompt -ErrorAction SilentlyContinue))) {
        # HACK: Pre-define ZLocation wrapper function in order to prevent ZLocation
        # from creating a wrapper around the prompt function.
        #  - Watching PR #121 (2022/02) https://github.com/vors/ZLocation/pull/121
        #  - Watching Issue #117 (2022/02) https://github.com/vors/ZLocation/issues/117#issuecomment-985850990
        function ZLocationOrigPrompt {}
    }

    # Import needs to be after any other imports that modify the prompt.
    Import-Module ZLocation
    $zlocationEnabled = $true
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

if (Get-Command 'dotnet' -ErrorAction SilentlyContinue) {
    # PowerShell parameter completion shim for the dotnet CLI
    Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
        param($commandName, $wordToComplete, $cursorPosition)
        dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}
