#Requires -Module InvokeBuild

Task . Lint-PSScriptAnalyzer, Lint-MarkdownLint

Task Lint -Jobs Lint-PSScriptAnalyzer, Lint-MarkdownLint

Task Lint-MarkdownLint {
    Exec { markdownlint '**/*.md' --ignore 'nvim/node_modules' --ignore 'nvim/plugged' --ignore 'vim/plugged' --ignore 'WindowsPowerShell/Modules' --ignore 'powershell/Modules' }
}

Task Lint-PSScriptAnalyzer {
    $lintFiles = Get-ChildItem -Recurse -Path $PWD -Depth 1 -Include bootstrap.ps1, lint.ps1, .build.ps1, run.ps1

    $results = @()
    foreach ($x in $lintFiles) {
        $lintArgs = @{
            Path                = "$($x.Directory)\$($x.Name)";
            Settings            = "$(Join-Path $PSScriptRoot 'PSScriptAnalyzerSettings.psd1')";
            IncludeDefaultRules = $true;
            WarningAction       = 'Continue';
        }

        $r = Invoke-ScriptAnalyzer @lintArgs
        $results += $r
    }

    if ($results) {
        $results | Format-Table
    }
    Assert ($results.Count -eq 0) "Expected linting results of 0, but received $($results.Count)"
}
