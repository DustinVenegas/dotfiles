$sw = [System.Diagnostics.Stopwatch]::StartNew()
$env:EDITOR = 'nvim'
$global:profile_initialized = $false # Indicates if the interactive profile was initialized
$MaximumHistoryCount = 10000
$commandsExist = Get-Command -Name @('rg', 'choco', 'oh-my-posh', 'dotnet', 'zoxide') -ErrorAction Ignore | Select-Object -ExpandProperty Name # Batch to performantly check existence with Get-Command.

$script:PSDotfilesCfg = Invoke-Command {
    # Resolve symlinks to the script root.
    $sr = Get-Item $PSScriptRoot
    while ($sr.PSObject.Properties.Name -eq 'Target' -and $sr.Target) {
        $sr = Get-Item $sr.Target
    }

    [PSCustomObject]@{
        Path             = $sr.Parent
        PSModules        = Join-Path -Path $sr.Parent -ChildPath 'powershell-modules'
        LocalProfilePath = Join-Path -Path $sr -ChildPath 'local.profile.ps1'
    }
}

# Optional local.profile.ps1 for profile machine-specific profile functions.
if ($PSDotfilesCfg.LocalProfilePath -and (Test-Path $PSDotfilesCfg.LocalProfilePath)) {
    . $PSDotfilesCfg.LocalProfilePath
}

# Add modules to the PowerShell modules search path.
@($PSDotfilesCfg.PSModules) |
    Where-Object { Test-Path $_ } |
    Where-Object { ($env:PSModulePath -split [System.IO.Path]::PathSeparator) -notcontains $_ } |
    ForEach-Object { $env:PSModulePath += [System.IO.Path]::PathSeparator + $_ }

# Add to the PATH for PowerShell sessions.
@("$HOME/.local/share/powershell/Scripts") |
    Where-Object { Test-Path $_ } |
    Where-Object { ($env:PATH -split [System.IO.Path]::PathSeparator) -notcontains $_ } |
    ForEach-Object { $env:PATH += [System.IO.Path]::PathSeparator + $_ }

# Initialize-Interactive performs one-time initialize for an interactive profile. Delays first prompt.
function Initialize-Interactive {
    # Set PSReadLine Options.
    Remove-PSReadLineKeyHandler -Chord @(
        'Ctrl+x,Ctrl+e', # ??? replaced with ViEditVisually
        'Ctrl+t', # Rebind "swap characters" with Fuzzy-Find.
        'Ctrl+r'  # Rebind "reverse search" with Fuzzy-History.
    )

    Set-PSReadLineKeyHandler -Chord 'Ctrl+x,Ctrl+e' -Function ViEditVisually
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete # Auto-completion menu on tab
    Set-PSReadLineKeyHandler -Chord 'Ctrl+Shift+c' -Function CaptureScreen # Interactively copy lines

    # Import-Module -Name Terminal-Icons
    Import-Module PSFzf
    Set-PsFzfOption -TabExpansion -GitKeyBindings -EnableAliasFuzzyEdit -EnableAliasFuzzyHistory -EnableAliasFuzzyKillProcess -EnableAliasFuzzySetLocation -EnableAliasFuzzyZLocation -EnableAliasFuzzyGitStatus

    if ($IsLinux -or $IsMacOS) {
        # PSUnixUtilCompleters enables argument completion for Linux binaries. Data is based on shell competions loaded into a zsh/bash.
        Import-Module Microsoft.PowerShell.UnixCompleters
    }

    if ($commandsExist -match 'oh-my-posh*') {
        @(oh-my-posh init pwsh --config="$HOME/.dotfiles-prompt.omp.json" --print) -join [System.Environment]::NewLine | Invoke-Expression
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

    Set-PSReadLineKeyHandler -Key Ctrl+Shift+b `
        -BriefDescription BuildCurrentDirectory `
        -LongDescription 'Build the current directory' `
        -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert('dotnet build')
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
}

function prompt {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', 'prompt', Justification="prompt is included in pwsh")]
    param()

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

if ($commandsExist -match 'zoxide*') {
    $hook = 'prompt'
    if ($commandsExist -match 'oh-my-posh*') { $hook = 'none' }

    # Import zoxide environment.
    (zoxide init --hook "$hook" powershell | Out-String) | Invoke-Expression

    # Enable oh-my-posh to control the prompt and update Zoxide after commands.
    if ((Test-Path function:\__zoxide_hook) -and ($commandsExist -match 'oh-my-posh*')) {
        function global:Set-ZoxidePoshContext {
            # Update Zoxide directory context.
            $null = __zoxide_hook
        }

        # After-command hook for oh-my-posh.
        New-Alias -Name 'Set-PoshContext' -Value 'Set-ZoxidePoshContext' -Scope Global -Force
    }
}

function Get-SourceLocations {
    Get-ChildItem -Directory "$HOME/Source" -Recurse -FollowSymlink -Depth 2 -Force -WarningVariable wa -WarningAction SilentlyContinue | Select-Object -ExpandProperty FullName
    $wa | Where-Object { $PSItem -notlike 'Skip already-visited directory *'} | Write-Warning
}
function Get-SourceLocation { Get-SourceLocations | Invoke-Fzf }
function Set-SourceLocation { Get-SourceLocations | Invoke-Fzf | Set-Location }
function Push-SourceLocation { Get-SourceLocations | Invoke-Fzf | Push-Location }
function Edit-SourceLocation {
    $sl = Get-SourceLocations | Invoke-Fzf
    code $sl
}

Set-Alias -Name esl -Value Edit-SourceLocation
Set-Alias -Name gsl -Value Get-SourceLocation
Set-Alias -Name psl -Value Push-SourceLocation
Set-Alias -Name ssl -Value Set-SourceLocation

$sw.Stop()
Write-Host "Initilizing profile.ps1: $($sw.ElapsedMilliseconds)ms"
