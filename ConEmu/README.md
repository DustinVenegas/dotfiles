# ConEmu

Dotfiles for [ConEmu](https://conemu.github.io/). ConEmu is a terminal
multiplexer and console emulator for Microsoft Windows.

## Setup

Run the `ConEmu/bootstrap.ps1` script in an Administrator PowerShell console:

```powershell
./ConEmu/bootstrap.ps1
```

Administrator Mode is required to create Symbolic Links.

## Configuration

`ConEmu.xml` is symbolically linked to `$env:AppData/Roaming/Code/User/`.

## Custom Key Bindings

    - ``WIN+` `` (Global): Minimize/Restore ConEmu.
      Changed from ``CTRL+` `` due to conflicting key binding in VSCode for
      Show/Hide Terminal.
    - ``Win+Alt+` `` (User): Recreate active console.
      Changed from ``WIN+` `` due to Global Minimize/Restore ConEmu keybinding.
