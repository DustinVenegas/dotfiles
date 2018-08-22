# iTerm2

[iTerm2](https://www.iterm2.com/) is an alternative terminal for MacOS. It benchmarks well, and plays especially nice with unix-based applications like vim, tmux, etc.

## Installation

`brew cask install iterm2`

## Configuration

You should try closing iTerm2 then running [`./bootstrapsh`](./bootstrap.sh). Restart iTerm2. Verify how your preferences are loaded through iTerm2 -> Preferences.
- "Load preferences from a custom folder or URL", checked
- "Save changes to folder when iTerm2 quits", checked
- "Settings Path", `$HOME/dotfiles/iTerm2
