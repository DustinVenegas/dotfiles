<#
    .SYNOPSIS
        Get your CI pipe going.
#>
#Requires -Version 5
[CmdletBinding()]
param()
begin {
    Remove-Module -Name Dotfiles -Force -ErrorAction SilentlyContinue
}
process {
    # Lint PowerShell files directly related to the dotfiles repository.
    $lintFiles = Get-ChildItem -Recurse -Path $PWD -Depth 1 -Include bootstrap.ps1
    $lintFiles += Get-ChildItem lint.ps1, run.ps1
    foreach ($x in $lintFiles) {
        $lintArgs = @{
            Path                = "$($x.Directory)\$($x.Name)";
            Settings            = "$(Join-Path $(Get-Location) 'PSScriptAnalyzerSettings.psd1')";
            IncludeDefaultRules = $true;
            WarningAction       = 'Continue';
        }
        Invoke-ScriptAnalyzer @lintArgs
    }

    markdownlint '**/*.md' --ignore 'nvim/node_modules' --ignore 'nvim/plugged' --ignore 'vim/plugged' --ignore 'WindowsPowerShell/Modules' --ignore 'powershell/Modules'
}

