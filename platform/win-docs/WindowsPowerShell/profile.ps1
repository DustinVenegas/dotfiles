################################################################################
# Global Variables
################################################################################
$MaximumHistoryCount=1024

# expand symbolic links
$dotfilesLocation = $MyInvocation.MyCommand.Source.Directory
Get-Item $MyInvocation.MyCommand.Source | Select-Object -ExpandProperty Target | Get-Item | Select-Object -ExpandProperty Directory | Set-Variable -Name dotfilesLocation
$dotfilesLocation = Resolve-Path -Path (Join-Path $dotfilesLocation ..)

################################################################################
# Welcome Message
################################################################################

# Load the (optional) local.profile.ps1
$localProfilePath = Join-Path $PSScriptRoot 'local.profile.ps1'
if (Test-Path $localProfilePath) {
    . $localProfilePath
}

# When the current directory is a SymbolicLink, resolve the link target and
$dotfilesPSModules = "$HOME\.dotfiles\powershell-modules"
if (Test-Path -Path $dotfilesPSModules) {
    if (($env:PSModulePath -split ';') -NotContains $dotfilesPSModules) {
        Write-Verbose "Adding $dotfilesPSModules to $($env:PSModulePath -Split ';')"
        $env:PSModulePath += ";$dotfilesPSModules"
    }
} else {
    Write-Warning "Could not find the custom powershell-modules directory. Some features and functions may be unavailable."
}

if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
} else {
    Write-Verbose @"
PSModule posh-git is missing! Git prompts will be disabled.

Either run .\bootstrap.ps1 or install the module manually.
"@
}

if (Get-Module -ListAvailable -Name RipGrep) {
    Import-Module RipGrep
}

################################################################################
# Set Window Properties
################################################################################
function SetWindowTitle() {
    # Set the window title
    # [Console History Number][Current Directory] [Console Host Name::Console Host Version]

    # Obtain the last history record and add one to see what our "current"
    # history is going to be after we execute this command.
    $currentHistoryIndex = (Get-History | Sort-Object 'id' -Descending | Select-Object -First 1).id + 1

    $host.Ui.RawUi.WindowTitle = "[#$currentHistoryIndex][$(Get-Location)] [$($Host.Name)::$($Host.Version)]"
}

################################################################################
# Map PSDrives
################################################################################
function Set-DotfilesDrives {
    @(
        ('Dotfiles', (Resolve-Path(Join-Path $PSScriptRoot '..')), "Personal Dotfiles Repository from $PSScriptRoot"),
        ('Scripts', (Resolve-Path(Join-Path $PSScriptRoot '\Scripts')), "Powershell Scripts from $PSScriptRoot\Scripts")
    ) | ForEach-Object {
        New-PSDrive `
            -Name $_[0] `
            -PSProvider FileSystem `
            -Root $_[1] `
            -Description $_[2] `
            -Scope 'Global' | Out-Null
    }
}

################################################################################
# Aliases
################################################################################
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias -Name nvi -Value nvim | Out-Null
    Set-Alias -Name nvq -Value nvim-qt | Out-Null
}

if (Get-Command rg -ErrorAction SilentlyContinue) {
    # If no ripgrep path is set, but a configuration exists, use it.
    if (($env:RIPGREP_CONFIG_PATH -eq '') -and (Test-Path "$HOME/.ripgreprc")) {
        $env:RIPGREP_CONFIG_PATH = "$HOME/.ripgreprc"
    }

    if (Get-Command fzf -ErrorAction SilentlyContinue) {
        # fzf (Fuzzy Finder)
        #   - Use rg (RipGrep) if available
        #   - Filename list
        # NOTE: Should be same as ../nvim/init.vim
        #   !!EXCEPT FOR!! the --vimdiff parameter; it will cause fzf errors
        $env:FZF_DEFAULT_COMMAND = 'rg --files'
    }
}

################################################################################
# Customize Prompt
################################################################################
function Shorten-Path([string] $path) {
    $loc = $path.Replace($HOME, '~')
    # remove prefix for UNC paths
    $loc = $loc -Replace '^[^:]+::', ''
    # make path shorter like tabs in Vim,
    # handle paths starting with \\ and . correctly
    return ($loc -Replace '\\(\.?)([^\\])[^\\]*(?=\\)', '\$1$2')
}

if (Get-Command -Name 'oh-my-posh' -ErrorAction SilentlyContinue) {
    $variation = '.minimal'

    if ($env:TERM_PROGRAM -eq 'VSCode') { $variation = '' } # VSCode
    if ($env:WT_SESSION) { $variation = '' } # Windows Terminal

    $ompTheme = Join-Path $HOME ".dotfiles-prompt${variation}.omp.json"
    if (Test-Path $ompTheme) {
        Write-Host "Theme is $ompTheme"
        oh-my-posh --init --shell pwsh --config "$ompTheme" | Invoke-Expression
    } else {
        Write-Warning "Oh snap, missing oh-my-posh theme at $ompTheme"
    }
}

Import-Module JunkDrawer
Set-DotfilesDrives
