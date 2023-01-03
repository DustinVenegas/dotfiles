Param(
    [Parameter()]
    $Count = 100,

    [Parameter()]
    [Switch] $Preview
)

<#
.SYNOPSIS
    Perform a benchtest of your PowerShell profile.
.DESCRIPTION
    Load Powershell (or Preview) X number of times with NO profile, and with profile, and compare the average loading times.
.PARAMETER Count
    Specify the number of consoles to load for testing.
.PARAMETER Preview
    Specify whether to test again pwsh-preview or not.
    With this present, the tests will use pwsh-preview.
.EXAMPLE
    Test-PowerShellProfilePerformance -Count 50
    Description
    -----------
    Loop through testing your powershell profile 50 times.
    This is 50 times PER console. With profile and without.
.NOTES
    Author: matthewjdegarmo
    Github: https://github.com/matthewjdegarmo
#>
Function Test-PowerShellProfilePerformance() {
    [CmdletBinding()]
    Param(
        [Parameter()]
        $Count = 100,

        [Parameter()]
        [Switch] $Preview
    )

    Begin {
        If ($Preview.IsPresent) {
            $Pwsh = 'pwsh-preview'
        } Else {
            $Pwsh = 'pwsh'
        }
        If (-Not(Get-Command $Pwsh -ErrorAction SilentlyContinue)) {
            Throw "The command '$Pwsh' does not exist on this system."
        }
    }

    Process {
        $Result = @{}

        $NoProfile = 0
        1..$Count | ForEach-Object {
            $Percent = $($_ / $Count) * 100
            Write-Progress -Id 1 -Activity "$($Pwsh.ToUpper()) - No Profile" -PercentComplete $Percent
            $NoProfile += (Measure-Command {
                    &$Pwsh -noprofile -command 1
                }).TotalMilliseconds
        }
        Write-Progress -Id 1 -Activity "$($Pwsh.ToUpper()) - No Profile" -Completed
        $Result['NoProfile_Average'] = "$($NoProfile/$Count)`ms"

        $WithProfile = 0
        1..$Count | ForEach-Object {
            $Percent = $($_ / $Count) * 100
            Write-Progress -Id 1 -Activity "$($Pwsh.ToUpper()) - With Profile" -PercentComplete $Percent
            $WithProfile += (Measure-Command {
                    &$Pwsh -command 1
                }).TotalMilliseconds
        }
        Write-Progress -Id 1 -Activity "$($Pwsh.ToUpper()) - With Profile" -Completed
        $Result['Profile_Average'] = "$($WithProfile/$Count)`ms"

        $Result['Measure_Script'] = Measure-Script -Path .\powershell\profile.ps1 | Sort-Object -Property executionTime

        Return $Result
    }
}

Test-PowerShellProfilePerformance @args
