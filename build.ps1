<#
    .SYNOPSIS
        Get your CI pipe going.
#>
#Requires -Version 5
[CmdletBinding()]
param()
begin {
    Remove-Module -Name Dotfiles -Force -ErrorAction SilentlyContinue

    function Write-ScriptAnalyzerAnalysis {
        [CmdletBinding()]
        param($analysis)

        $errors = $analysis | Where-Object { $_.Severity -eq 'Error' }
        $warnings = $analysis | Where-Object { $_.Severity -eq 'Warning' }

        if ($errors -OR $warnings) {
            Write-Warning -Message "PSScriptAnalyzer encountered $($errors.Count) error$(if ($errors.Count -ne 1) { 's' }) and $($warnings.Count) warning$(if ($warnings.Count -ne 1) { 's' })."

            $errors + $warnings | Format-Table RuleName, Severity, @{
                Label      = 'RelativeScriptPath';
                Expression = {
                    Get-Item $_.ScriptPath | Resolve-Path -Relative
                }
            }, Line, Message -AutoSize
        }
    }
}
process {
    # Locate all the bootstrap.ps1 files
    $lintFiles = Get-ChildItem -Recurse -Path $PWD -Depth 1 -Include bootstrap.ps1
    $results = @()
    foreach ($x in $lintFiles) {
        $lintArgs = @{
            Path                = "$($x.Directory)\bootstrap.ps1";
            Settings            = "$(Join-Path $(Get-Location) 'PSScriptAnalyzerSettings.psd1')";
            IncludeDefaultRules = $true;
            WarningAction       = 'Continue';
        }
        $results += @(Invoke-ScriptAnalyzer @lintArgs)
    }

    Write-ScriptAnalyzerAnalysis $results
}
