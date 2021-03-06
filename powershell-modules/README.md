# powershell-modules

Shared PowerShell Modules.

## Modules

PSModulePath (`$env:PSModulePath`) should contain two dotfiles-related entries.

* `$HOME/Documents/WindowsPowerShell/Modules` contains system-specific
  PSModules (_git-ignored_)
* `$HOME/Documents/powershell-modules/Modules-Dotfiles` contains dotfiles-specific
  PSModules

### Dotfiles-Specific `Modules-Dotfiles/`

`$HOME/Documents/powershell-modules/Modules-Dotfiles` contains dotfiles-specific PSModules

#### JunkDrawer

Stores dotfiles-specific functions, POC CmdLets, and other "misc" code."

### System-Specific `Modules/`

`$HOME/Documents/WindowsPowerShell/Modules` contains system-specific PSModules (_git-ignored_)

#### PSFzf

[PSFzf](https://github.com/kelleyma49/PSFzf) is a PowerShell Module that
contains extensions for [fzf](https://github.com/junegunn/fzf), aka June Gunn's
Fuzzy Finder.

##### Bindings

* `CTRL+T` Files or directories
* `CTRL+R` History
* `ALT-C` Directories
* `ALT-A` Historical Arguments
* `Invoke-Fzf` PowerShell CmdLet

#### posh-git

[Posh-Git](https://github.com/dahlbyk/posh-git) adds Git bindings and prompts to
PowerShell.
