[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification="Literally the PowerShell Host")]
param(
)

<#
Windows PowerShell console (shell) specific profile
#>

Set-StrictMode -Version Latest

function Write-MessageOfTheDay
{
    Write-Figlet -f='small' "$env:Username@" | Write-Host -ForegroundColor yellow
    Write-Figlet -f='smslant' $env:COMPUTERNAME | Write-Host -ForegroundColor Green
    Write-Output "I'd like to see you move up to the emu class, where I think you belong."
}

Write-MessageOfTheDay

Set-StrictMode -Off
