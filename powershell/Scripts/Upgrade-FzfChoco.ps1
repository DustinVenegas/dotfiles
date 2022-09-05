#Requires -RunAsAdministrator
#Requires -Version 6.0
<#
.SYNOPSIS
Upgrade outdated packages from a fzf of non-pinned packages.

.DESCRIPTION
Runs choco upgrade on selected packages. Packages are selected
from a fzf fuzzy-finder listing outdated packages.
#>

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseCompatibleCommands", "Join-String")] # Requires version 6.0
param()

choco outdated --limit-output --ignore-pinned |
    fzf --multi --border --reverse --bind 'ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all' --header "`nCTRL+A-Select All`tCTRL+D-Deselect All`tCTRL+T-Toggle All`n" --delimiter='\|' --nth=1 --exit-0 |
    ForEach-Object {
        ($_ -Split '\|')[0].Trim()
    } |
    Set-Variable -Name outdated

if ($outdated) {
    $joined = $outdated -Join ';'
    Write-Verbose "About to upgrade $($outdated.Length) packages"
    choco upgrade --userememberedoptions "$joined" -y
}
