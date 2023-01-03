<#PSScriptInfo
.VERSION 1.0

.GUID c8dde45c-025a-4354-bf6e-eebe26d432c1

.AUTHOR Joel 'Jaykul' Bennett

.COMPANYNAME PoshCode.org

.COPYRIGHT Copyright 2019, Joel Bennett. All Rights Reserved

.TAGS Measure, LinesOfCode

.LICENSEURI https://opensource.org/licenses/MIT

.PROJECTURI https://gist.github.com/Jaykul/e1056d5182d0c5566a22f72387abf741

.ICONURI

.EXTERNALMODULEDEPENDENCIES PSScriptAnalyzer

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

.PRIVATEDATA

#>

#requires -module @{ModuleName = "PSScriptAnalyzer"; ModuleVersion = "1.17.1" }

<#
    .SYNOPSIS
        Count the lines of code in PowerShell script (or module) files
    .DESCRIPTION
        Counts the lines of code based on the compact One True Brace style (requires PSScriptAnalyzer)
        In -Verbose mode, outputs the OTBS formatted script with line number next to the lines that count
    .EXAMPLE
        Measure-Script $profile.CurrentUserAllHosts -Verbose

        Counts the number of lines in your profile script, and shows you which ones counted in verbose output
#>
[CmdletBinding()]
param(
    # The path to a script (.ps1) or module (.psm1) file
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory)]
    [Alias("PSPath")]
    [string]$Path,

    # If set, counts lines with nothing but a closing brace (default is not to count them)
    # See https://gist.github.com/Jaykul/e1056d5182d0c5566a22f72387abf741 for further details
    [switch]$IncludeTrailingBraces
)
process {
    # For lines of code, reformat everything to OTBS to produce meaningful numbers
    $Reformatted = Invoke-Formatter (Get-Content $Path -Raw) -Settings @{
        IncludeRules = @(
            'PSPlaceOpenBrace',
            'PSPlaceCloseBrace',
            'PSUseConsistentWhitespace',
            'PSUseConsistentIndentation',
            'PSAlignAssignmentStatement'
        )

        Rules        = @{
            PSPlaceOpenBrace           = @{
                Enable             = $true
                OnSameLine         = $true
                NewLineAfter       = $true
                IgnoreOneLineBlock = $false
            }

            PSPlaceCloseBrace          = @{
                Enable             = $true
                NewLineAfter       = $false
                IgnoreOneLineBlock = $true
                NoEmptyLineBefore  = $false
            }

            PSUseConsistentIndentation = @{
                Enable          = $true
                Kind            = 'space'
                IndentationSize = 4
            }

            PSUseConsistentWhitespace  = @{
                Enable         = $true
                CheckOpenBrace = $true
                CheckOpenParen = $true
                CheckOperator  = $true
                CheckSeparator = $true
            }

            PSAlignAssignmentStatement = @{
                Enable         = $true
                CheckHashtable = $true
            }
        }
    } -Verbose:$false

    $Ast = [System.Management.Automation.Language.Parser]::ParseInput($Reformatted, $Path, [ref]$Null, [ref]$Null)

    $LineNumbers = $(
        foreach ($Extent in $Ast.FindAll( {$Args[0] -ne $Ast}, $true).Extent) {
            $Extent.StartLineNumber
            if ($IncludeTrailingBraces) {
                $Extent.EndLineNumber
            }
        }
    ) | Sort-Object -Unique

    [PSCustomObject]@{
        PSTypeName = "CodeMetrics"
        "LinesOfCode" = $LineNumbers.Count
    }

    if ($VerbosePreference -notin "SilentlyContinue", "Ingore") {
        $Reformatted = $Reformatted -split "`n"
        $count = 0
        foreach($line in 0..$Reformatted.Count) {
            if(($line + 1) -in $LineNumbers) {
                Write-Verbose ("{0,3:d} {1}" -f (++$count), $Reformatted[$line])
            } else {
                Write-Verbose ("    " + $Reformatted[$line])
            }
        }
    }
}