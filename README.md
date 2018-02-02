# Dustin Venegas's dotfiles

A collection of configurations, customizations, settings, etc known as a [dotfiles](https://dotfiles.github.io/) repository, by [Dustin Venegas](https://www.dustinvenegas.com/). This repository should be cloned to `~/dotfiles/`. There's some old setup scripts lying around, but they're a bit crusty.


## Layout

  * [`.vim`](./.vim/README.md) - [Vim](http://www.vim.org/) modal editor configuration. Expects to be [source](http://vimdoc.sourceforge.net/htmldoc/repeat.html#:source) loaded from `~/.vimrc`
  * [`nvim`](./nvim/README.md) - [Neovim](https://www.neovim.io/) modal editor configuration. Expects to be [source](https://neovim.io/doc/user/repeat.html#:source) loaded from the appropriate [`XGD_BASE_DIR`](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
  * [`provision`](./provision/README.md) - Provisioning scripts for this dotfiles repository
  * [`WindowsPowershell`](./WindowsPowerShell/README.md) - Windows Powershell configuration files and scripts.
