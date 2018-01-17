################################################################################
# Global Variables
################################################################################
$env:EDITOR = 'gvim.exe'
$MaximumHistoryCount=1024 

################################################################################
# Welcome Message
################################################################################
Clear-Host

function Write-Figlet {
    # Completely unnecessary and do it regardless.
    if(Get-command figlet) {
        figlet $args
    } else {
        $args
    }
}

Write-Figlet -f='small' "$env:Username@" | Write-Host -ForegroundColor yellow
Write-Figlet -f='smslant' $env:COMPUTERNAME | Write-Host -ForegroundColor Green
Write-Host "I'd like to see you move up to the emu class, where I think you belong."

if ((Get-Module -ListAvailable -Name posh-git) -ne $null)
{
    Import-Module posh-git

    $global:GitPromptSettings.AfterText = ']'
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
# Scripts Drive
if (Test-Path "$PSScriptRoot\scripts") {
    New-PSDrive -name 'Scripts' `
        -psProvider FileSystem `
        -root "$PSScriptRoot\Scripts" `
        -description "Powershell Scripts from $PSScriptRoot" | Out-Null
}

################################################################################
# Custom Functions
################################################################################
function exp([string] $loc = '.') {
   # open explorer in this directory
   explorer "/e,"$loc""
}

function Edit-HostProfile{
   GVim $profile
}

function Edit-Profile{
   GVim $profile
}

function Edit-Hosts{
   GVim c:\windows\system32\drivers\etc\hosts
}

function Search-ForLines {
    param (
        [Parameter(Mandatory=$True)]
        [string]$pattern,
        [Parameter(Mandatory=$False)]
        [string]$filter
    )

    Get-ChildItem $path -Filter $filter -Recurse | 
        Select-String $pattern | %{ 
            "$($_.Path):$($_.LineNumber) - $($_.Line)"
        }
}

function New-Guid {
    [guid]::NewGuid()
}

function Convert-ToHex ([long] $dec) {
   return "0x" + $dec.ToString("X")
}

function Convert-ToBinHex($array) {
   $str = New-Object system.text.stringbuilder
   $array | %{
      [void]$str.Append($_.ToString('x2'));
   }
   return $str.ToString()
}

function Convert-FromBinHex([string]$binhex) {
   $arr = New-Object byte[] ($binhex.Length/2)
   for ( $i=0; $i -lt $arr.Length; $i++ ) {
      $arr[$i] = [Convert]::ToByte($binhex.substring($i*2,2), 16)
   }
   return $arr
}

function Get-Hash($value, $hashalgo = 'MD5') {
   $tohash = $value
   if ( $value -is [string] ) {
      $tohash = [text.encoding]::UTF8.GetBytes($value)
   }
   $hash = [security.cryptography.hashalgorithm]::Create($hashalgo)
   return convert-tobinhex($hash.ComputeHash($tohash));
}

function Test-Administrator {
    ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

<#
.DESCRIPTION Builds a Basic header-authenticaion string from a PSCredential instance
#>
function New-HttpBasicAuthValue([PSCredential]$credential)
{
    $pair = "$($credential.UserName):$($credential.GetnetworkCredential().Password)"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)

    return "Basic $base64"
}

<#
.DESCRIPTION Builds a header dictionary with a basic auth value using the supplied credential
#>
function New-HttpBasicAuthHeader([PSCredential]$credential)
{
    $basicAuthValue = New-HttpBasicAuthValue $credential
    return @{ Authorization = $basicAuthValue }
}

################################################################################
# Aliases
################################################################################
New-Alias -Name grep -Value Search-ForLines

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
