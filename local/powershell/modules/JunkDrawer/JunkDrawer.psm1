function Search-ForLines {
    <#
    .SYNOPSIS Search children by a filter for the pattern recursively
    #>
    param (
        [Parameter(Mandatory=$True)]
        [string]$pattern,
        [Parameter(Mandatory=$False)]
        [string]$filter
    )

    Get-ChildItem $path -Filter $filter -Recurse |
        Select-String $pattern | ForEach-Object {
            "$($_.Path):$($_.LineNumber) - $($_.Line)"
        }
}

function Convert-ToHex ([long] $dec) {
    <#
    .SYNOPSIS Returns the string Hexidecimal representation of a long
    #>
    return "0x" + $dec.ToString("X")
}

function Convert-ToBinHex($array) {
    <#
    .SYNOPSIS Converts an input string, to a string, formatted in binary
    #>
    $str = New-Object System.Text.StringBuilder
    $array | ForEach-Object {
        $str.Append($_.ToString('x2')) | Out-Null
    }
    return $str.ToString()
}

function Convert-FromBinHex([string]$binhex) {
    <#
    .SYNOPSIS Converts the input hex values to ASCII bytes
    #>
    $arr = New-Object byte[] ($binhex.Length/2)
    for ( $i=0; $i -lt $arr.Length; $i++ ) {
        $arr[$i] = [Convert]::ToByte($binhex.substring($i*2, 2), 16)
    }
    return $arr
}

function Edit-Dotfiles {
    $sr = (Get-Item $PSScriptRoot).Parent.Parent

    & code $sr
}

function Edit-HostsFile {
    <#
    .SYNOPSIS Edits the machine host file
    #>
    &$env:EDITOR c:\windows\system32\drivers\etc\hosts
}

function New-Guid {
    <#
    .SYNOPSIS Creates a new System.Guid object
    #>
    [System.Guid]::NewGuid()
}

function Test-AdministratorRole {
    <#
    .SYNOPSIS Test if the current user is part of the built-in "Administrator" role
    #>
    $currentPrincipal = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent());
    $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

<#
.DESCRIPTION Builds a Basic header-authenticaion string from a PSCredential instance
#>
function New-HttpBasicAuthValue([PSCredential]$credential) {
    $pair = "$($credential.UserName):$($credential.GetnetworkCredential().Password)"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)

    return "Basic $base64"
}

<#
.DESCRIPTION Builds a header dictionary with a basic auth value using the supplied credential
#>
function New-HttpBasicAuthHeader([PSCredential]$credential) {
    $basicAuthValue = New-HttpBasicAuthValue $credential
    return @{ Authorization = $basicAuthValue }
}

<#
    .SYNOPSIS
    A custom prompt for PowerShell Core that uses VT100 escape codes.
#>
function HandCraftedPromptForPowerShell1 {
    # Prompt:
    #   §
    #   |--- Green if no errors. Red if errors

    # our theme
    $colorStatus = if ($? -eq $true) { [ConsoleColor]::DarkCyan } else { [ConsoleColor]::Red }
    $colorDelimiter = [ConsoleColor]::DarkCyan
    $colorHost = [ConsoleColor]::Green
    $colorLocation = [ConsoleColor]::Cyan
    $colorCloud = [ConsoleColor]::Magenta

    Write-Host "$([char]0x0A7) " -NoNewline -ForegroundColor $colorStatus

    if (Get-Variable -Name 'PSSenderInfo' -ErrorAction SilentlyContinue) {
        # Display the computer name if this is a remote session
        # $PSSenderInfo is only available in PSSession to detect remoting.
        # See `Get-Help about_Automatic_Variables for more information
        Write-Host "$(($env:COMPUTERNAME).ToLower()) " -NoNewline -ForegroundColor $colorHost
    }

    Write-Host '{' -NoNewline -ForegroundColor $colorDelimiter
    Write-Host "$(shorten-path (pwd).Path)" -NoNewline -ForegroundColor $colorLocation
    Write-Host '} ' -NoNewline -ForegroundColor $colorDelimiter

    if (Get-Module 'AzureRM.profile') {
        $azureContext = Get-AzureRmContext
        if ($azureContext -and $azureContext.Subscription -and $azureContext.Subscription.Name) {
            Write-Host "$([char]0x2601)$($azureContext.Subscription.Name) " -NoNewline -ForegroundColor $colorCloud
        }
    }

    Write-VcsStatus

    SetWindowTitle

    Return ' '
}

<#
    .SYNOPSIS
    A custom prompt for PowerShell Core that uses VT100 escape codes.
#>
function HandCraftedPromptForPowerShellCore {
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

    $sep = ' '

    #####################
    # first line
    #####################
    $p = $il

    # Status indicator
    $lastCmdOK_C = 'red'
    $lastCmdGlyph = 'X'
    if ($lastCmdOK) {
        $lastCmdOK_C = 'darkcyan'
        $lastCmdGlyph = ''
    }
    $p += "$($fgc.darkcyan)[$($fgc[$lastCmdOK_C])$lastCmdGlyph$($fgc.default)${sep}"

    # Current location
    $cl = $executionContext.SessionState.Path.CurrentLocation.Path
    switch ($cl) {
        { $_.StartsWith($HOME) } { $cl = $_.Replace("$HOME", '~') }
        { $_.StartsWith('/mnt/c/') } { $cl = $_.Replace('/mnt/c/', 'WINDOWS:/') }
    }
    $p += "$($bgc.darkcyan)$($fgc.black)$($cl)$($fgc.default)$($bgc.default)"

    # Git Status via posh-git
    $p += "$(Write-VcsStatus)"

    # End the line with an unstyled character to create a boundry, otherwise
    # resizing a terminal may cause effects to 'leak' until the end of line.
    $p += "${sep}$($fgc.darkcyan)]$($fgc.default)"

    #####################
    # second line
    #####################

    # Move the cursor to the second line.
    $p += "$([System.Environment]::NewLine)"

    # Debugger active
    if (Test-Path variable:PSDebugContext) {
        $p += "$($fgc.yellow)[DBG]:$($fgc.default)${sep}"
    }

    # Current Time
    $p += "$($fgc.darkcyan)$([DateTime]::now.ToString("HH:mm"))$($fgc.default)${sep}"

    # Directory stack astericks
    $p += "$('*' * ($(Get-Location -Stack).Count))"

    # Command number
    $p += "$($fgc.darkgrey)$((Get-History -Count 1).id + 1)$($fgc.default)"

    # Prompt ('>') **AND** nested-prompt (also '>')
    $p += "$($fgc.darkcyan)>$('>' * ($nestedPromptLevel))$($fgc.default)${sep}"

    #####################
    # Cleanup
    #####################

    # Reset $LASTEXITCODE so the value is available to the terminal.
    $global:LASTEXITCODE = $lastLastExitCode

    # The final prompt is a single string with terminal escape codes to reduce screen tearing.
    return "$p"
}

$exportModuleMemberParams = @{
    Function = @(
        'Edit-HostsFile',
        'Edit-Dotfiles',
        'New-Guid',
        'New-HttpBasicAuthValue',
        'New-HttpBasicAuthHeader',
        'Test-AdministratorRole',
        'Search-ForLines',
        'HandCraftedPromptForPowerShell1',
        'HandCraftedPromptForPowerShellCore'
    )
}

Export-ModuleMember @exportModuleMemberParams
