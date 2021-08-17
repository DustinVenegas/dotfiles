#Requires -Module InvokeBuild

Task . Lint-PSScriptAnalyzer, Lint-MarkdownLint

Task Lint -Jobs Lint-PSScriptAnalyzer, Lint-MarkdownLint, Lint-Shellcheck

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

Task Lint-Shellcheck {
    $lintFiles = Get-ChildItem -File -Recurse -Path $PWD -Depth 2 -Include '*.sh', 'bash*'
    #Exec { shellcheck --external-sources $lintFiles }
    shellcheck --color=auto --external-sources $lintFiles
    $succeeded, $lec = $?, $LASTEXITCODE

    Assert ($succeeded) "Expected shellcheck to emit successful command, but received $succeeded"
    Assert ($lec -eq 0) "Expected shellcheck to return zero, but received $lec"
}
