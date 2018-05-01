# Git

You might start with `git list-alises`!

## Setup

Just run `./git/bootstrap.ps1`.

## Configuration

Configuration files are Symlinked from the dotfiles repository to their expected paths.

  - `$HOME/.gitconfig` points to `gitconfig`
  - `$HOME/.gitignore` points to `gitignore`
  - `$HOME/.gitconfig_os` points to `gitconfig_os_windows`, etc

Use `$HOME/.gitconfig_local` for any machine-specific configuration.
