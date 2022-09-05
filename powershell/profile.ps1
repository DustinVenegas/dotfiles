$sw = [System.Diagnostics.Stopwatch]::StartNew()
$env:EDITOR = 'nvim'
$global:profile_initialized = $false # Indicates if the interactive profile was initialized
$MaximumHistoryCount = 10000

$script:cfg = Invoke-Command {
    # Resolve symlinks to the script root.
    $sr = Get-Item $PSScriptRoot
    while ($sr.PSObject.Properties.Name -eq 'Target' -and $sr.Target) {
        $sr = Get-Item $sr.Target
    }

    [PSCustomObject]@{
        DotfilesLocation  = $sr.Parent
        DotfilesPSModules = Join-Path -Path $sr.Parent -ChildPath 'powershell-modules'
        LocalProfilePath  = Join-Path -Path $sr -ChildPath 'local.profile.ps1'
    }
}

# Optional local.profile.ps1 for profile machine-specific profile functions.
if ($cfg.LocalProfilePath -and (Test-Path $cfg.LocalProfilePath)) {
    . $cfg.LocalProfilePath
}

# Adds powershell-modules to the PowerShell modules search path.
@($cfg.DotfilesPSModules) |
    Where-Object { Test-Path $_ } |
    Where-Object { ($env:PSModulePath -split [System.IO.Path]::PathSeparator) -notcontains $_ } |
    ForEach-Object { $env:PSModulePath += [System.IO.Path]::PathSeparator + $_ }

# Initialize-Interactive performs one-time initialize for an interactive profile. Delays first prompt.
function Initialize-Interactive {
    $commandsExist = Get-Command -Name @('choco', 'oh-my-posh', 'dotnet') -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name # Batch to performantly check existence with Get-Command.

    # Set PSReadLine Options.
    Remove-PSReadLineKeyHandler -Chord @(
        'Ctrl+x,Ctrl+e', # ??? replaced with ViEditVisually
        'Ctrl+t', # Rebind "swap characters" with Fuzzy-Find.
        'Ctrl+r'  # Rebind "reverse search" with Fuzzy-History.
    )

    Set-PSReadLineKeyHandler -Chord 'Ctrl+x,Ctrl+e' -Function ViEditVisually
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete # Auto-completion menu on tab

    Import-Module -Name Terminal-Icons
    Import-Module PSFzf
    Set-PsFzfOption -TabExpansion -GitKeyBindings -EnableAliasFuzzyEdit -EnableAliasFuzzyHistory -EnableAliasFuzzyKillProcess -EnableAliasFuzzySetLocation -EnableAliasFuzzyZLocation -EnableAliasFuzzyGitStatus

    if ($IsLinux -or $IsMacOS) {
        # PSUnixUtilCompleters enables argument completion for Linux binaries. Data is based on shell competions loaded into a zsh/bash.
        Import-Module Microsoft.PowerShell.UnixCompleters
    }

    if ($commandsExist -match 'oh-my-posh*') {
        # oh-my-posh --init --shell pwsh --config "$(Join-Path $script:cfg.DotfilesLocation 'oh-my-posh' 'dotfiles-prompt.omp.json' -Resolve)" | Invoke-Expression
        @(oh-my-posh init pwsh --config="$($cfg.DotfilesLocation)/oh-my-posh/dotfiles-prompt.omp.json" --print) -join [System.Environment]::NewLine | Invoke-Expression
    }

    if ($env:ChocolateyInstall) {
        @("$env:ChocolateyInstall\helpers\ChocolateyProfile.psm1") | Where-Object { Test-Path $_ } | ForEach-Object { Import-Module $_ }
    }

    if ($commandsExist -match 'dotnet*') {
        Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
            param($commandName, $wordToComplete, $cursorPosition)
            dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
    }

    # Setup PSDrives
    if ([System.IO.Directory]::Exists([System.IO.Path]::Combine("$HOME", 'Source'))) {
        New-PSDrive -Scope Script -Root ~/Source -Name Source -PSProvider FileSystem -ErrorAction Ignore > $Null
    }
}

function prompt {
    if ($global:profile_initialized -ne $true) {
        $sw.Start()
        $global:profile_initialized = $true
        try {
            Initialize-Interactive

            # Call the newly Initialized prompt function immediately
            prompt
        } catch {
            Write-Error 'Could not initialize prompt:'
            Write-Error $_
        }
        $sw.Stop()

        Write-Host "Initilizing Interactive: $($sw.ElapsedMilliseconds)ms"
        $sw = $null
    }
}

$sw.Stop()
Write-Host "Initilizing profile.ps1: $($sw.ElapsedMilliseconds)ms"
