# Git

You might start with `git list-alises`!

## Installation

Windows - With Chocolatey

`./git/bootstrap.ps1`

macOS - With Homebrew

```sh
./bash/bootstrap.sh && brew bundle
```

Linux - Ubuntu

```sh
./bash/bootstrap.sh && \
    sed 's/#.*//' ubuntu-installs.txt | \
    xargs sudo apt-get install`
```

## Configuration

Use `$HOME/.gitconfig_local` for any machine-specific configuration.

Configuration files are symlinked from the dotfiles repository to `$HOME` paths.

- `$HOME/.gitconfig` points to `gitconfig`
- `$HOME/.gitignore` points to `gitignore`
- `$HOME/.gitconfig_os` points to `gitconfig_os_windows`, `gitconfig_os_macos`, etc
