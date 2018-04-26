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

    function Test-LinkTarget
    {
        param
        (
            $path,
            $expectedTarget
        )

        $pathFileInfo = Get-Item $path -ErrorAction SilentlyContinue

        # 'HardLink', 'SymbolicLink', or 'Junction'
        if ($pathFileInfo.LinkType)
        {
            $linkTargetPath = Resolve-Path $pathFileInfo.Target;
            $targetPath = Resolve-Path $target;

            return $linkTargetpath.Path -eq $targetpath.Path
        }
        else
        {
            Write-Verbose @"
Test-LinkTarget failed on $path!
    Expected -Not `$Null
    Received $($pathFileInfo.LinkType)
"@

            return $false
        }
    }

    function Confirm-LinkTo
    {
        param($path, $target)

        <#
        Note, SymbolicLinks require admin to create but are flexibly across drives/files/folders
              Author assumes links are symbolic links or known/managed outside this script.
        #>

        if (-Not (Test-Path $target))
        {
            Write-Error "Expected target ($target) to exist, but was misssing!"
            return $false
        }

        if (Test-Path $path)
        {
            if (Test-LinkTarget -Path $path -Target $target)
            {
                Write-Verbose "OK! $path is already pointed to $target"
                return $true
            }
            else
            {
                Write-Error @"
Confirm-LinkTo failed!
    Path: $path
    Target: $target

Expected Path to be a SymbolicLink or Junction to Target.

    a) Is Path a SymbolicLink or Junction? Check the target!
    b) Is Path a regular folder? Backup, then rename/move Path!

Re-run this script after resolving Path to continue.
"@
            }
        }
        else
        {
            # Nothing at $path, so just create it!
            $createdFileInfo = New-Item -Type SymbolicLink -Path $path -Value $target
            Write-Verbose "CREATED: $($createdFileInfo.Name), a $($createdFileInfo.LinkType), pointed at $($createdFileInfo.Target)"
            return $true
        }
    }
}
Process
{
    # Maps: HOME/Documents/WindowsPowerShell/ -> $dotfiles/WindowsPowerShell/
    $hardLinks = @{ (Join-Path -Path "$HOME/Documents/" -ChildPath 'WindowsPowerShell/') = $PSScriptRoot; }
    $expectedPsGalleryModules = 'posh-git','PSFzf','PSScriptAnalyzer'

    if ($uninstall)
    {
        # Remove HardLinks
        $hardLinks.Keys | Get-Item -ErrorAction SilentlyContinue | Foreach-Object { $_.Delete() }
    }
    else
    {
        $hardLinks.Keys | Foreach-Object { Confirm-LinkTo -Path $_ -Target $hardLinks[$_] } | Out-Null

        # Confirm PSGallery is trusted so we're not prompted
        Confirm-PSRepositoryTrusted 'PSGallery' | Out-Null

        # Confirm the expected modules are at least installed
        $expectedPsGalleryModules | Foreach-Object { Install-Module -Repository PSGallery $_ -Scope CurrentUser } | Out-Null

        # Optional (slow)
        Approve-UpdateHelp
        Approve-UpdatePSGalleryModule
    }
}
