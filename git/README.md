# Git

You might start with `git list-alises`!

## Installation

  - Windows: `./git/bootstrap.ps1`
    - Depends on PowerShell and Chocolatey
  - MacOS (POSIX/Brew): `./git/bootstrap.sh`
    - Depends on POSIX and Homebrew

## Configuration

Use `$HOME/.gitconfig_local` for any machine-specific configuration.

Configuration files are Symlinked from the dotfiles repository to `$HOME` paths.

  - `$HOME/.gitconfig` points to `gitconfig`
  - `$HOME/.gitignore` points to `gitignore`
  - `$HOME/.gitconfig_os` points to `gitconfig_os_windows`, `gitconfig_os_macos`, etc
