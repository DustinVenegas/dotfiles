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
   $str = new-object system.text.stringbuilder
   $array | %{
      [void]$str.Append($_.ToString('x2'));
   }
   return $str.ToString()
}

function Convert-FromBinHex([string]$binhex) {
   $arr = new-object byte[] ($binhex.Length/2)
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

################################################################################
# Aliases
################################################################################
New-Alias -Name grep -Value Search-ForLines


################################################################################
# Customize Prompt 
################################################################################
function shorten-path([string] $path) {
   $loc = $path.Replace($HOME, '~')
   # remove prefix for UNC paths
   $loc = $loc -replace '^[^:]+::', ''
   # make path shorter like tabs in Vim,
   # handle paths starting with \\ and . correctly
   return ($loc -replace '\\(\.?)([^\\])[^\\]*(?=\\)','\$1$2')
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

    write-host "$([char]0x0A7) " -nonewline -f $colorStatus

    if ($PSSenderInfo)
    {
        # Display the computer name if this is a remote session
        # $PSSenderInfo is only available in PSSession to detect remoting.
        # See `Get-Help about_Automatic_Variables for more information
        write-host ($env:COMPUTERNAME).ToLower() -nonewline -f $colorHost
    }

    write-host ' {' -nonewline -f $colorDelimiter
    write-host (shorten-path (pwd).Path) -nonewline -f $colorLocation
    write-host '} ' -nonewline -f $colorDelimiter

    Write-VcsStatus

    SetWindowTitle

    Return ' '
}
