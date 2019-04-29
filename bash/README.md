# Bash

Bash profiles, aliases, etc.

## Installation

### MacOS (POSIX/Brew)

```sh
./bash/bootstrap.sh && brew bundle
```

### Linux

```sh
./bash/bootstrap.sh && sed 's/#.*//' ubuntu-installs.txt | xargs sudo apt-get install
```

## Configuration

Configuration files are Symlinked from the dotfiles repository to `$HOME` paths.

### Localhost Configuration

A optional, localhost specific configuration can be placed at
`$HOME/.bashrc.local` and is run after the main `~/.bash_profile` script is.

### XOrg/xsrv/xcvsrv on Bash on Windows

Install an X Server for Windows. As of 2019, [vcxsrv](https://sourceforge.net/projects/vcxsrv/)
is recommended.

- Chocolatey: `choco install vcxsrv`

Afterwards, place the following line in your `$HOME/.bashrc.local` configuration.

```sh
export DISPLAY=localhost:0.0
```
