<#
    .Synopsis
        Configure iTerm for this Dotfiles configuration
#>
[CmdletBinding()]
#Requires -Version 5
param()
begin {
    Import-Module -Name (Resolve-Path (Join-Path $PSScriptRoot ../powershell-modules/Dotfiles/Dotfiles.psm1))
    Set-StrictMode -Version latest
}
process {
    if (-Not (Test-OSPlatform 'Darwin')) {
        $config = Get-DotfilesConfig
        Write-Information "Skipping $($PSScriptRoot) because only Darwin is supported. Current OS/Platform is $($config.SimplifiedOSPlatform)."
        return
    }

    # Check for Terminal.App *before* installing iTerm2.
    if ("$env:TERM_PROGRAM" -ne "Apple_Terminal") {
        # iTerm2 fails to set some settings when installed from Homebrew using a
        # terminal other than Terminal.app to run 'brew'. iTerm2 fails to set some
        # macOS settings using the 'defaults' binary when run from iTerm2.
        Write-Error "Expected MacOS built-in Terminal.app, but was $TERM_PROGRAM. Execution errored.\n"
        return
    }

    Invoke-Everytime -Name 'Write_iTerm_Defaults' -ScriptBlock {
        # Point iTerm's preferences at this dotfiles folder
        defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$PSScriptRoot"

        # Use preferences in PrefsCustomFolder
        defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

        # Write preferences on exit
        defaults write com.googlecode.iterm2.plist "NoSyncNeverRemindPrefsChangesLostForFile_selection" -bool false
    }
}
