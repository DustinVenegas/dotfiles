# RipGrep

[RipGrep](https://github.com/BurntSushi/ripgrep/) is a search utility based
around regex. It works well cross-platform, can replace grep, and can respect
`.gitignore` files. This makes it a great addition for shells and editors.

## Setup

Install ripgrep with

chocolatey: `choco install ripgrep -y`

[Ubuntu 18.04](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7#ubuntu-1804)

```bash
# Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb

# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb

# Update the list of products
sudo apt-get update

# Enable the "universe" repositories
sudo add-apt-repository universe

# Install PowerShell
sudo apt-get install -y powershell
```

Then setup the dotfiles configuration with `./RipGrep/bootstrap.ps1`.

## Configuration

The `RIPGREP_CONFIG_PATH` environment variable must be set in order for the
default configuration to be used.

The following files are Symlinked from the dotfiles repository to their expected
paths.

- `$HOME/.ripgreprc` points to [`ripgreprc`](./ripgreprc)
