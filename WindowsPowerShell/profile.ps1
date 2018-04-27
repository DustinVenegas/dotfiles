################################################################################
# Global Variables
################################################################################
$env:EDITOR = 'gvim.exe'
$MaximumHistoryCount=1024

################################################################################
# Welcome Message
################################################################################
if (($env:PSModulePath -Split ';') -NotContains $PSScriptRoot)
{
    Write-Verbose "Added $PSScriptRoot/Modules to $PSModulePath"
    $env:PSModulePath += ";$(Join-Path -Path $PSScriptRoot -ChildPath Modules/)"
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


if (Test-Path C:\ProgramData\Chocolatey\lib\ripgrep\tools\_rg.ps1)
{
    # Source the ripgrep configuration
. "$($env:ChocolateyInstall)\lib\ripgrep\tools\_rg.ps1"
}

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
                -Description $_[2] | Out-Null
        }
}

################################################################################
# Aliases
################################################################################
if (Get-Alias grep -ErrorAction SilentlyContinue)
{
    Write-Verbose "Alias: 'grep' was an alias bound to $((Get-Alias Grep).DisplayName). Updated!"
    Set-Alias -Name grep -Value rg
}
else
{
    New-Alias -Name grep -Value rg | Out-Null
}

################################################################################
# Plugins
################################################################################
# Set the fzf (Fuzzy Finder) default to use rg (RipGrep)
# Include (u) .gitignore masks, (uu) and hidden; NOT (uuu) binary
$env:FZF_DEFAULT_COMMAND = 'rg -uu --files --vimgrep'

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

    if ($PSSenderInfo)
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

Set-DotfilesDrives
