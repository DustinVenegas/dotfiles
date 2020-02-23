# Module checks
if (Get-Module RipGrep) { return }

if (Get-Command rg -ErrorAction SilentlyContinue)
{
    if (Test-Path C:\ProgramData\Chocolatey\lib\ripgrep\tools\_rg.ps1)
    {
        # Source PowerShell completion for RipGrep.
        . "$($env:ChocolateyInstall)\lib\ripgrep\tools\_rg.ps1"
    }

    # Functions for aliases
    function Invoke-RipGrepUnrestrictedIgnored { &rg -u $args}
    function Invoke-RipGrepUnrestrictedIgnoredHidden { &rg -uu $args}
    function Invoke-RipGrepUnrestrictedIgnoredHiddenBinary { &rg -uuu $args}

    # RipGrep Aliases
    New-Alias -Name rgu -Value Invoke-RipGrepUnrestrictedIgnored | Out-Null
    New-Alias -Name rguu -Value Invoke-RipGrepUnrestrictedIgnoredHidden | Out-Null
    New-Alias -Name rguuu -Value Invoke-RipGrepUnrestrictedIgnoredHiddenBinary | Out-Null

    # Overwrite 'grep' if it exists as an alias
    if (Get-Alias grep -ErrorAction SilentlyContinue)
    {
        Write-Verbose "Alias: 'grep' was an alias bound to $((Get-Alias Grep).DisplayName). Updated!"
        Set-Alias -Name grep -Value rg
    }
    else
    {
        New-Alias -Name grep -Value rg | Out-Null
    }
}

function Get-RipGrepConfigPath
{
    return $env:RIPGREP_CONFIG_PATH
}

Export-ModuleMember -Function 'Get-RipGrep*','Invoke-RipGrep*' -Alias 'grep','rgu*'
