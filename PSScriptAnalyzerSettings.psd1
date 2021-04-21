@{
    Severity     = @('Error', 'Warning')

    # CodeFormattingOTBS
    IncludeRules = @(
        'PSPlaceOpenBrace',
        'PSPlaceCloseBrace',
        'PSUseConsistentWhitespace',
        'PSUseConsistentIndentation',
        'PSAlignAssignmentStatement',
        'PSUseCorrectCasing',
        'PSUseCompatibleCommands',
        'PSUseCompatibleSyntax'
    )
    ExcludeRules = @()

    # CodeFormattingOTBS
    Rules        = @{
        PSPlaceOpenBrace           = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }

        PSPlaceCloseBrace          = @{
            Enable             = $true
            NewLineAfter       = $false
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $false
        }

        PSUseConsistentIndentation = @{
            Enable              = $true
            Kind                = 'space'
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            IndentationSize     = 4
        }

        PSUseConsistentWhitespace  = @{
            Enable                          = $true
            CheckInnerBrace                 = $true
            CheckOpenBrace                  = $true
            CheckOpenParen                  = $true
            CheckOperator                   = $false
            CheckPipe                       = $true
            CheckPipeForRedundantWhitespace = $false
            CheckSeparator                  = $true
            CheckParameter                  = $false
        }

        PSAlignAssignmentStatement = @{
            Enable         = $true
            CheckHashtable = $true
        }

        PSUseCorrectCasing         = @{
            Enable = $true
        }

        PSUseCompatibleCommands    = @{
            Enable         = $true

            # Lists the PowerShell platforms we want to check compatibility with
            TargetProfiles = @(
                'win-4_x64_10.0.18362.0_7.0.0_x64_3.1.2_core', # PowerShell 7 on Windows 10
                'win-48_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework', # PowerShell 5.1 on Windows 10 1809
                'ubuntu_x64_18.04_6.2.4_x64_4.0.30319.42000_core' # PowerShell 6 on Ubuntu 18.04 LTS
                'ubuntu_x64_18.04_7.0.0_x64_3.1.2_core' # PowerShell 7 on Ubuntu 18.04 LTS
            )
        }

        PSUseCompatibleSyntax      = @{
            Enable         = $true

            # Simply list the targeted versions of PowerShell here
            TargetVersions = @(
                '3.0',
                '5.1',
                '6.2'
            )
        }
    }
}
