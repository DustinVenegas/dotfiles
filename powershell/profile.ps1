$env:EDITOR = 'nvim'
$MaximumHistoryCount = 10000

$dotfilesLocation = (Get-Item $MyInvocation.MyCommand.Source).Directory
$dotfilesLocation | Select-Object -ExpandProperty Target | Set-Variable -Name dotfilesLocation
$dotfilesLocation = Resolve-Path -Path (Join-Path $dotfilesLocation ..)

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

if (Get-Command -Name 'oh-my-posh' -ErrorAction SilentlyContinue) {
    $ompDir = Join-Path $dotfilesLocation 'oh-my-posh'

    $variation = '.minimal'

    if ($env:TERM_PROGRAM -eq 'VSCode') { $variation = '' } # VSCode
    if ($env:WT_SESSION) { $variation = '' } # Windows Terminal
    $ompTheme = Resolve-Path (Join-Path $ompDir "dotfiles-prompt${variation}.omp.json")
    Write-Host "Theme is $ompTheme"
    oh-my-posh --init --shell pwsh --config "$ompTheme" | Invoke-Expression
}


