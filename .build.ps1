#Requires -Module InvokeBuild
#Requires -Module PSScriptAnalyzer

Task . Lint

Task Lint -Jobs Lint-PSScriptAnalyzer, Lint-MarkdownLint, Lint-Shellcheck

Task Lint-MarkdownLint {
    Exec { markdownlint '**/*.md' --ignore 'todo.md' --ignore 'nvim/node_modules' --ignore 'nvim/plugged' --ignore 'vim/plugged' --ignore 'WindowsPowerShell/Modules' --ignore 'powershell/Modules' }
}

Task Lint-PSScriptAnalyzer {
    # File types to include
    $include = '*.ps1', '*.psm1'

    $files = Get-ChildItem -Recurse -Path $PWD -Depth 1 -Include $include

    # powershell core
    $files += Get-ChildItem -Path PowerShell -Exclude Modules | Get-ChildItem -Recurse -File -Include $include

    # powershell-modules
    $files += Get-ChildItem -Path powershell-modules -Recurse -Include $Include

    # WindowsPowerShell
    $files += Get-ChildItem -Path WindowsPowerShell -Exclude Modules | Get-ChildItem -Recurse -File -Include $include

    $results = @()
    foreach ($x in $files) {
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
        $results | ft

        $filesWithErrors = $results.ScriptPath | Get-Unique | Resolve-Path -Relative
        Assert ($results.Count -eq 0) "PSScriptAnalyzer: expected 0 linting violations but received $($results.Count) across $($filesWithErrors.Count) files:`n  $($filesWithErrors -Join "`n  ")"
    }
}

Task Lint-Shellcheck {
    $lintFiles = Get-ChildItem -File -Recurse -Path $PWD -Depth 2 -Include '*.sh', 'bash*', 'zshrc'
    #Exec { shellcheck --color=auto --format=gcc --external-sources $lintFiles }
    shellcheck --color=auto --format=gcc --external-sources $lintFiles
    $succeeded, $lec = $?, $LASTEXITCODE

    Assert ($succeeded) "Expected shellcheck to emit successful command, but received $succeeded"
    Assert ($lec -eq 0) "Expected shellcheck to return zero, but received $lec"
}
