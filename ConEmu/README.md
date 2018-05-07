# ConEmu

Dotfiles for [ConEmu](https://conemu.github.io/).

## Setup

In an Administrator PowerShell console: `./ConEmu/bootstrap.ps1`. Administrator Mode is required to create Symbolic Links.

## Configuration

Configuration files are Symlinked from the dotfiles repository to their expected paths.

## Custom Key Bindings

  - ``WIN+``` (Global): Minimize/Restore ConEmu.
    - Changed from ``CTRL+``` due to conflicting key binding in VSCode for Show/Hide Terminal.
  - ``Win+Alt+``` (User): Recreate active console.
    - Changed from ``WIN+``` due to Global Minimize/Restore ConEmu keybinding.
