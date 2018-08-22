#!/bin/bash

# strict-ish mode: fail on errors, undefined variables, output pipefails
set -euo pipefail

if [[ "$OSTYPE" != "darwin"* ]]; then
    # Ha, there's no iTerm2 on Linux
    printf "WARNING! Expected operating system to be MacOS (Darwin), but was $OSTYPE\n" >&2
fi

if [[ "$TERM_PROGRAM" != "Apple_Terminal" ]]; then
    # Apparently iTerm2, and other terms, can't interact with MacOS sometimes.
    # Defaults had issues writing via iTerm2. Homebrew Cask recommeended only using Terminal.app
    # so applications can interact with MacOS.
    printf "WARNING! Expected MacOS built-in Terminal.app, but was $TERM_PROGRAM. Some commands may misbehave.\n" >&2
fi

BashScriptRoot="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# iTerm2
##########
# Point iTerm's preferences at this dotfiles folder
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$BashScriptRoot"

# Use preferences in PrefsCustomFolder
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

# Write preferences on exit
defaults write com.googlecode.iterm2.plist "NoSyncNeverRemindPrefsChangesLostForFile_selection" -bool false
