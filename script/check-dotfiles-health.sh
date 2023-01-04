#!/bin/sh

# check-dotfiles-health.sh - dotfiles smoke tests for POSIX environments.

ec=0 # script exit code

# Check for command errors in a fresh environment without envvars.
if ! env -i pwsh -NoProfile -Command ". $HOME/.config/powershell/profile.ps1"; then ec=1; echo "error: pwsh"; fi
if ! env -i bash -c "source $HOME/.bashrc"; then ec=1; echo "error: bash .bashrc"; fi
if ! env -i zsh -c "set -e; source $HOME/.zshrc"; then ec=1; echo "error: zsh .zshrc"; fi
if ! env -i git version 1>/dev/null; then ec=1; echo "error: git version";  fi
if ! env git config --get user.name 1>/dev/null; then ec=1; echo "error: git user.name missing";  fi
if ! env git config --get user.email 1>/dev/null; then ec=1; echo "error: git user.email missing";  fi

rm nvimlog -f
nvim -V1nvimlog +qall # Output errors (-V1) to a file. File data indicates an error.
if [ -s nvimlog ]; then
	ec=1; 
	echo "error: nvim log contained content at: nvimlog"
	cat nvimlog
fi

# May be better ways to detect errors in vim/neovim.
#
# rm vimlog -f
# vim -V1vimlog +qall # Output errors (-V1) to a file. File data indicates an error.
# if [ -s vimlog ]; then
# 	ec=1; 
# 	echo "error: vim log contained content at: vimlog"
# 	cat vimlog
# fi

exit $ec