################################################################################
# Global Variables
################################################################################
$env:EDITOR = 'gvim.exe'
$MaximumHistoryCount=1024

################################################################################
# Welcome Message
################################################################################
$dotfilesLocalPath = Join-Path "$PSScriptRoot" 'Modules-Dotfiles/'
if (($env:PSmodulePath -Split ';' | %{ Join-Path $_ '' }) -NotContains ($dotfilesLocalPath))
{
    Write-Verbose "Adding $dotfilesLocalPath to $PSModulePath"
    $env:PSModulePath += ";$dotfilesLocalPath"
}

if ((Get-Module -ListAvailable -Name posh-git) -ne $null)
{
    Import-Module posh-git

    # Removes extra space
    $global:GitPromptSettings.AfterText = ']'
}
else
{
    Write-Verbose @"
PSModule posh-git is missing! Git prompts will be disabled.

Either run .\bootstrap.ps1 or install the module manually.
"@
}

Import-Module RipGrep

################################################################################
# Set Window Properties
################################################################################
function SetWindowTitle() {
    # Set the window title
    # [Console History Number][Current Directory] [Console Host Name::Console Host Version]

    # Obtain the last history record and add one to see what our "current"
    # history is going to be after we execute this command.
    $currentHistoryIndex = (get-history | `
            Sort-Object 'id' -descending | `
            Select-Object -First 1).id + 1

    $host.Ui.RawUi.WindowTitle = "[#$currentHistoryIndex][$(Get-Location)] [$($Host.Name)::$($Host.Version)]"
}

################################################################################
# Map PSDrives
################################################################################
function Set-DotfilesDrives
{
    @(
        ('Dotfiles',(Resolve-Path(Join-Path $PSScriptRoot '..')),"Personal Dotfiles Repository from $PSScriptRoot"),
        ('Scripts',(Resolve-Path(Join-Path $PSScriptRoot '\Scripts')),"Powershell Scripts from $PSScriptRoot\Scripts")
    ) | Foreach-Object {
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
if (Get-Command nvim -ErrorAction SilentlyContinue)
{
    Set-Alias -Name nvi -Value nvim | Out-Null
    Set-Alias -Name nvq -Value nvim-qt | Out-Null
}

if (Get-Command rg -ErrorAction SilentlyContinue)
{
    # If no ripgrep path is set, but a configuration exists, use it.
    if (($env:RIPGREP_CONFIG_PATH -eq '') -and (Test-Path "$HOME/.ripgreprc"))
    {
        $env:RIPGREP_CONFIG_PATH = "$HOME/.ripgreprc"
    }

    if (Get-Command fzf -ErrorAction SilentlyContinue)
    {
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
   return ($loc -Replace '\\(\.?)([^\\])[^\\]*(?=\\)','\$1$2')
}

$VerbosePreference = 'Continue'

function Prompt {
    # Prompt:
    #   §
    #   |--- Green if no errors. Red if errors

    # our theme
    $colorStatus = if ($? -eq $true) {[ConsoleColor]::DarkCyan} else { [ConsoleColor]::Red }
    $colorDelimiter = [ConsoleColor]::DarkCyan
    $colorHost = [ConsoleColor]::Green
    $colorLocation = [ConsoleColor]::Cyan
    $colorCloud = [ConsoleColor]::Magenta

    Write-Host "$([char]0x0A7) " -NoNewLine -ForegroundColor $colorStatus

    #if ($PSSenderInfo)
    if (Get-Variable -Name 'PSSenderInfo' -ErrorAction SilentlyContinue)
    {
        # Display the computer name if this is a remote session
        # $PSSenderInfo is only available in PSSession to detect remoting.
        # See `Get-Help about_Automatic_Variables for more information
        Write-Host "$(($env:COMPUTERNAME).ToLower()) " -NoNewLine -ForegroundColor $colorHost
    }

    Write-Host '{' -NoNewLine -f $colorDelimiter
    Write-Host "$(shorten-path (pwd).Path)" -NoNewLine -ForegroundColor $colorLocation
    Write-Host '} ' -NoNewLine -f $colorDelimiter

    if (Get-Module 'AzureRM.profile')
    {
        $azureContext = Get-AzureRmContext
        if ($azureContext -and $azureContext.Subscription -and $azureContext.Subscription.Name)
        {
            Write-Host "$([char]0x2601)$($azureContext.Subscription.Name) " -NoNewLine -ForegroundColor $colorCloud
        }
    }

    Write-VcsStatus

    SetWindowTitle

    Return ' '
}

Import-Module JunkDrawer
$localProfilePath = Join-Path $PSScriptRoot 'local.profile.ps1'
if (Test-Path (Join-Path $PSScriptRoot 'local.profile.ps1'))
{
    . $localProfilePath
}

Set-DotfilesDrives
