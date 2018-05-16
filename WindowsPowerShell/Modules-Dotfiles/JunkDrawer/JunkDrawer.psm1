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
        Select-String $pattern | %{
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
    $array | Foreach-Object {
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
        $arr[$i] = [Convert]::ToByte($binhex.substring($i*2,2), 16)
    }
    return $arr
}

function Edit-HostsFile{
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

$exportModuleMemberParams = @{
    Function = @(
        'Edit-HostsFile',
        'New-Guid',
        'New-HttpBasicAuthValue',
        'New-HttpBasicAuthHeader',
        'Test-AdministratorRole',
        'Search-ForLines'
    )
}

Export-ModuleMember @exportModuleMemberParams
