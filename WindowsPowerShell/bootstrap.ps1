<#
    .Synopsis
        Configure PowerShell and necessary modules for Dotfiles

    .Description
        Bootstraps the PowerShell portion of the Dotfiles Repository by performing
        actions such as installing PSModules, updating common items, and adding
        the necessary file links.

    .Parameter Uninstall
        Removes appropriate installed files outside of the Dotfiles repository.


    .Parameter Confirm
        Approves all prompts

    .Example
        # Run bootstrapper, approving everything
        .\bootstrap.ps1 -Confirm

    .Example
        # Uninstall
        .\bootstrap.ps1 -Uninstall

    .Notes
        The dotfiles WindowsPowerShell directory is Symlinked into $HOME/Documents.
        Afterward, there is a single PSModules folder at ./Modules. It will contain
        modules bundled with this Dotfiles repository and installed PSModules.
#>
#Requires -Version 5
#Requires -RunAsAdministrator
[CmdletBinding()]
param(
    [switch]$confirm,
    [switch]$uninstall
)
Begin
{
    $dotfilesModulePath = Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1)
    Import-Module -Name $dotfilesModulePath
    Set-StrictMode -Version Latest
    $ErrorActionPreference = "Stop"

    # ====== Functions ======

    function Confirm-PSRepositoryTrusted
    {
        param
        (
            $name
        )

        if ((Get-PSRepository -Name $name).InstallationPolicy -ne 'Trusted')
        {
            # Trust scripts (remove warnings) when downloading from PSGallery
            Set-PSRepository -Name $name -InstallationPolicy 'Trusted'
        }
    }

    function Get-UserInputYesNo
    {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification="Literally the PowerShell Host", Scope="Function")]
        param
        (
            $message
        )

        if (($PSCmdlet.MyInvocation.BoundParameters["confirm"]) `
            -and ($PSCmdlet.MyInvocation.BoundParameters["confirm"].IsPresent -eq $true))
        {
            # Confirms all actions
            return $true
        }

        while($true)
        {
            $input = Read-Host "$message (Y/N)?"

            switch ($input.ToUpper())
            {
                'Y' { return $true }
                ''  { return $false }
                'N' { return $false }

                default { Write-Host "Invalid input: $input"; continue; }
            }
        }
    }

    function Approve-UpdateHelp
    {
        if (Get-UserInputYesNo 'Update all help files')
        {
            # HACK: Ignore errors due to 'Failed to update Help for the module(s)' errors
            Update-Help -ErrorAction SilentlyContinue
        }
    }

    function Approve-UpdatePSGalleryModule
    {
        if (Get-UserInputYesNo 'Update all PSGalleryModules')
        {
            Update-Module
        }
    }
}
Process
{
    # Maps: HOME/Documents/WindowsPowerShell/ -> $dotfiles/WindowsPowerShell/
    $symlinks = @{ (Join-Path -Path "$HOME/Documents/" -ChildPath 'WindowsPowerShell/') = $PSScriptRoot; }
    $expectedPsGalleryModules = 'posh-git','PSFzf','PSScriptAnalyzer'

    if ($uninstall)
    {
        # Delete the symlinks that exist
        $symlinks.Keys | Where-Object { Test-DotfilesSymlink -Path $_ -Target $symlinks[$_] } | Foreach-Object { $_.Delete() }
    }
    else
    {
        # Create symlinks
        $symlinks.Keys | %{ Set-DotfilesSymbolicLink -Path $_ -Target $symlinks[$_] }

        # Confirm PSGallery is trusted so we're not prompted
        Confirm-PSRepositoryTrusted 'PSGallery' | Out-Null

        # Confirm the expected modules are at least installed
        $expectedPsGalleryModules | Foreach-Object { Install-Module -Repository PSGallery $_ -Scope CurrentUser } | Out-Null

        # Optional (slow)
        Approve-UpdateHelp
        Approve-UpdatePSGalleryModule
    }
}
