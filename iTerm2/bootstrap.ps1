<#
    .Synopsis
    Configure iTerm for this Dotfiles configuration
    .Description
    Bootstraps the iTerm portion of the Dotfiles repository
#>
#Requires -RunAsAdministrator
#Requires -Version 5
[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
param()
begin
{
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest

    $optWhatif = $true
    if ($PSCmdlet.ShouldProcess("Without Option: -whatif ")) {
        $optWhatif = $false
    }
}
process
{
    if (-Not ($OSTYPE -and $OSTYPE -Match "darwin*")) {
        Write-Warning "WARNING! Expected operating system to be MacOS (Darwin), but was $OSTYPE instead"
    } else {
        if ("$TERM_PROGRAM" -ne "Apple_Terminal") {
            # Apparently iTerm2, and other terms, can't interact with MacOS sometimes.
            # Defaults had issues writing via iTerm2. Homebrew Cask recommeended only using Terminal.app
            # so applications can interact with MacOS.
            Write-Warning "WARNING! Expected MacOS built-in Terminal.app, but was $TERM_PROGRAM. Some commands may misbehave.\n"
        }

        if ($optWhatIf) {
            Write-Verbose "Would have set a custom iTerm Perferences Folder by running macOS-specific commands"
        } else {
            # Point iTerm's preferences at this dotfiles folder
            defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$PSScriptRoot"

            # Use preferences in PrefsCustomFolder
            defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

            # Write preferences on exit
            defaults write com.googlecode.iterm2.plist "NoSyncNeverRemindPrefsChangesLostForFile_selection" -bool false
        }
    }
}
