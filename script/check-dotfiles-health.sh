#!/bin/sh

# check-dotfiles-health.sh - dotfiles smoke tests for POSIX environments.

ec=0 # script exit code

# Check for command errors in a fresh environment without envvars.
if ! env -i pwsh -NoProfile -Command ". $HOME/.config/powershell/profile.ps1"; then ec=1; echo "error: pwsh"; fi
if ! env -i bash .bashrc; then ec=1; echo "error: bash"; fi
if ! env -i zsh .zshrc; then ec=1; echo "error: bash"; fi
if ! env -i git version; then ec=1; echo "error: bash";  fi

rm nvimlog -f
nvim -V1nvimlog +qall # Output errors (-V1) to a file. File data indicates an error.
if [ -s nvimlog ]; then
	ec=1; 
	echo "error: nvim log contained content at ./nvimlog:"
	cat nvimlog
fi

rm vimlog -f 
vim -V1vimlog +qall # Output errors (-V1) to a file. File data indicates an error.
if [ -s vimlog ]; then
	ec=1; 
	echo "error: vim log contained content at ./vimlog:"
	cat vimlog
fi

exit $ec