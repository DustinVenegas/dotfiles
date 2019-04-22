# RipGrep

[RipGrep](https://github.com/BurntSushi/ripgrep/) is a search utility based around regex. It works well cross-platform, can replace grep, and can respect `.gitignore` files. This makes it a great addition for shells and editors.

## Setup

Just run `./RipGrep/bootstrap.ps1`.

## Configuration

The `RIPGREP_CONFIG_PATH` environment variable must be set in order for the default configuration to be used.

The following files are Symlinked from the dotfiles repository to their expected paths.

  - `$HOME/.ripgreprc` points to [`ripgreprc`](./ripgreprc)
