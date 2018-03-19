# PowerShell

Dotfiles for Windows PowerShell.

## Prerequisites

```ps1
Install-Module -Name PSFzf
Install-Module -Name posh-git
```

## Modules

PSModules of note.

### PSFzf

[PSFzf](https://github.com/kelleyma49/PSFzf) is a PowerShell Module that contains extensions for [fzf](https://github.com/junegunn/fzf), aka June Gunn's Fuzzy Finder.

#### Bindings

  * `CTRL+T` Files or directories
  * `CTRL+R` History
  * `ALT-C` Directories
  * `ALT-A` Historical Arguments
  * `Invoke-Fzf` PowerShell CmdLet

### posh-git

[Posh-Git](https://github.com/dahlbyk/posh-git) adds Git bindings and prompts to PowerShell.
