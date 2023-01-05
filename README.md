# Dustin Venegas's dotfiles

[dotfiles](https://dotfiles.github.io/) configuration files for [Dustin Venegas](https://www.dustinvenegas.com/)
that focuses on PowerShell, VSCode, neovim, and runs across Linux, macOS, and Windows platforms. Bootstrapping and platform specific scripts are located in `./scripts/`.

![build](https://github.com/DustinVenegas/dotfiles/actions/workflows/main.yml/badge.svg)

## Installation

Install any prerequisites for the specific platform and then run the bootstrapper at [`./script/check-dotfiles-health.sh`](./script/check-dotfiles-health.sh).

- POSIX-Based OS: `./script/bootstrap.sh --whatif --verbose`
- Windows OS:  `./script/bootstrap.ps1 -verbose -whatif`

## Health

Check the environment health using the check script at [`./script/check-dotfles-health.sh`](./script/check-dotfiles-health.sh).

## Why PowerShell Core?

Because piping objects with properties and functions is fun and useful.

```ps1
Get-ChildItem $HOME -Force | # items in $HOME
  Select-Object Name, @{
    Name="FirstLine";        
    Expression={Get-Content $_ -ReadCount 1 -ErrorAction Ignore}
  } | # object with Name and FirstLine.
  Tee-Object -Variable files | # save pipeline to a variable
  Format-Table # output as a table
```

![Approximate Command Output](assets/pwsh-demo.png)

## Components

- [bash](https://www.gnu.org/software/bash/) shell.  Local Configuration: `$HOME/.bashrc.local` [docs](https://www.gnu.org/software/bash/manual/bash.html)
- [Markdownlint](https://github.com/markdownlint/markdownlint) is a CLI tool used to lint Markdown files. [docs](https://github.com/markdownlint/markdownlint/blob/master/docs/configuration.md)
- [Kitty](https://github.com/kovidgoyal/kitty) is a terminal emulator for Unix-like platforms. Configuration at `$HOME/.config/kitty/`. [docs](https://sw.kovidgoyal.net/kitty/quickstart/#)
- [ripGrep](https://github.com/BurntSushi/ripgrep/) searches files like grep and also respects your .gitignore. Configuration must be set with envvar `RIPGREP_CONFIG_PATH`. [docs](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md)
- [git](https://git-scm.com/) SCM. Local Configuration: `$HOME/.gitconfig_local`. OS Configuration: `$HOME/.gitconfig_os`. [docs](https://git-scm.com/doc)
- [neovim](https://neovim.io/) is a modal editor and successor to vim that works cross platform on Linux, macOS, Windows, and others. [docs](https://neovim.io/doc/)
- [PowerShell Core](https://github.com/PowerShell/PowerShell) cross-platform object-oriented shell. [docs](https://learn.microsoft.com/en-us/powershell/)
- Windows PowerShell is a  Windows-only object-oriented shell.
- [zsh](https://zsh.sourceforge.io/) shell. [docs](https://zsh.sourceforge.io/Doc/)
- [oh-my-posh](https://ohmyposh.dev/) is a custom prompt that works across many platforms. [docs](https://ohmyposh.dev/docs/)
- [rclone](https://rclone.org/) provides programs to manage cloud storage, including mounting, syncing, cp/mv/ls/etc. [docs](https://rclone.org/docs/)
- [Windows Terminal](https://github.com/microsoft/terminal) is a terminal emulator and multiplexer for Microsoft Windows that supports unicode fonts. [docs](https://learn.microsoft.com/en-us/windows/terminal/customize-settings/startup)
- [wsl](https://learn.microsoft.com/en-us/windows/wsl/) Windows Subsystem for Linux. [docs](https://learn.microsoft.com/en-us/windows/wsl/)
- [vim](https://www.vim.org/) the OG modal editor. [docs](https://www.vim.org/docs.php)

## Examples

### Windows Terminal Running PowerShell

![Windows Terminal Console Window](assets/console-windows.png)

### bash on Ubuntu

![bash console on Ubuntu](assets/pwsh-ubuntu.png)

### pwsh on Windows

![pwsh console on Windows](assets/pwsh-win.png)

### nvim-qt

![nvim-qt](assets/nvim-qt.png)

## Related Projects

* [dotfiles](https://dotfiles.github.io/), your unofficial guide to dotfiles on GitHub.
* [smkent/dotfiles](https://github.com/smkent/dotfiles), dotfiles repository of
  Stephen Kent.
