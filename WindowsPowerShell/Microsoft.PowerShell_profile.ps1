<#
Windows PowerShell console specific profile
#>

# posh-git
if (Get-Module -ListAvailable posh-git) {
    Import-Module posh-git
}
