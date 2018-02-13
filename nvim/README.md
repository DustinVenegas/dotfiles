# neovim

[Neovim](https://www.neovim.io/) modal editor configuration for Dustin Venegas. 


## Setup

These instructions are based on the [Neovim Installation Instructions](https://github.com/neovim/neovim/wiki/Installing-Neovim).

### Windows

#### nvim Chocolatey Packages

[Chocolatey](https://chocolatey.org/) is recommended to install and maintain Neovim on Windows. 

[Install Chocolatey](https://chocolatey.org/install).

Open an elevated (admin) PowerShell Console and change directories to `<dotfiles checkout>/nvim`. Run Chocolatey against the [chocolatey-packages.config](./chocolatey-packages.config).

```ps1
cd $HOME/dotfiles/nvim/
choco install chocolatey-packages.config
```

#### `Neovim\bin` path in your System PATH Variable
Next, let's see if we have the environment variable available. Open a **new instance** of Powershell.

```ps1
# Should return c:\tools\neovim\Neovim\bin
[System.Environment]::GetEnvironmentVariable("PATH", "Machine") -Split ';' | Where-Object { $_ -like 'c:\tools\neovim\Neovim\bin*' }
```

Your PATH variable must contain an entry for Neovim's bin directory. The neovim Chocolatey package, as of 2018-02, created a directory at `c:\tools\neovim\Neovim\bin\`. You'll need to add your neovim bin diretcory to your System PATH.

```ps1
# set a variable pointing at your neovim directory
$neovimPath = 'C:\tools\neovim\Neovim\bin'

# AS ADMIN, appends $neovimPath variable contents to system PATH variable
[Environment]::SetEnvironmentVariable("PATH", "$($env:PATH);$neovimPath", "Machine")
```


### Source from `init.vim`

This dotfiles vim configuration expects to be [source](https://neovim.io/doc/user/repeat.html#:source) loaded from the appropriate [`XGD_BASE_DIR`](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html):
  * Windows: `~/AppData/Local/nvim/init.vim`
  * Linux: `~/.config/nvim/init.vim` 

Below is an example `init.vim` file which uses the default checkout location on a Windows machine.

```viml
" Add our git dotfiles checkout to neovim's rtp for loading scripts
set runtimepath^=~/dotfiles/nvim/

" Load our configuration
source ~/dotfiles/nvim/init.vim
```

_Note,_ Source loading the dotfiles configuration has pros and cons. Some operating systems don't posses full symlinking capabilities. Consistently source loading across all operating systems just makes things easier.



## Plugins

This configuration is intended to gracefully handle missing plugins, themes, and fonts. vim-plug is a hard depndency and is therefore committed directly to the repository. You'll need to run `:PlugInstall` in short order to load plugins, themes, etc.

Why do we take a hard dependency on vim-plug, but ignore the plugin submodules? Some plugins have different platform requirements. They've been for Windows compatability in the past. While not ideal for consistency, this has been sufficient for my needs.

**Note,** if you try to execute `nvim-qt.exe` and a window opens but never really loads then there might be a missing configuration issue. Run `nvim.exe` to ensure there are no configuration errors. You may have to run `:PlugInstall` using the command-line version, `nvim.exe`. 



### vim-plug

[junegunn/vim-plug](https://github.com/junegunn/vim-plug) is used to manage neovim plugins. It was selected for its simplicity. 

  * `:PlugInstall` installs the plugins defined.
  * `:PlugUpgrade` updates [`~/dotfiles/nvim/autoload/plug.vim`](./autoload/plug.vim) to the latest vim-plug version. After verifying the changes, they can be committed to the dotfiles repository for distribution.



### vim-gitgutter

[airblade/vim-gitgutter](https://github.com/airblade/vim-gitgutter) adds markers to the gutter that indicate if lines were added, modified, or removed in git. 

  * `:GitGutterToggle` toggles the feature on/off
  * `]c`, `[c`, goes to next and previous hunks



### junegunn/fzf

[junegunn/fzf](https://github.com/junegunn/fzf) is both the `fzf` source code and basic vim bindings for `fzf`.  `fzf` is a cross-platform "fuzzy finder". It takes lists and provides "fuzzy" filtering based on partial or near matches. 

This plugin depends on the `fzf` binary in your PATH. It adds the `FZF` ex-mode command to vim.

  * `:FZF`: Open fzf to the current directory (default)



#### External Dependencies

You can install `fzf` using a package manager.

  * Windows: `choco install fzf -y`
  * macOS: `brew install fzf`

Alternatively, the `junegun/fzf` plugin directory *is* the `fzf` source code. The `/bin` directory is already included in the search path. On a POSIX system, you could use a vim-plug "after" command to build `fzf`.

```viml
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
```

Windows would need to take on additional dependencies to perform the same installation style. This dotfiles repository prefers a manual installation due to differing commands on Windows and Linux.



### junegunn/fzf.vim

[junegunn/fzf.vim](https://github.com/junegunn/fzf.vim) contains vim-specific `fzf` bindings. This is the thing we customize in vim.

#### Bindings

  * `CTRL-T`/`CTRL-X`/`CTRL-V`: Open in new tab/split/vsplit
  * `:FzfSomeCommand!`: Fullscreen version of Fzf commands
  * `<C-x><C-k>`: Dictionary word complete

#### Customizations

  * `:Fzf<command>`: Prefix for all commands. Custom, in order to locate fzf specific functions easily.

#### Other

An `g:fzf_action` exists to configure bindings in addition to the default `CTRL-T`, `CTRL-X`, and `CTRL-V` versions.

