# neovim

[Neovim](https://www.neovim.io/) modal editor configuration for Dustin Venegas. 


## Setup

Install directly, or use your favorite package manager.


### Chocolatey
Note, you *may* need to append your Neovim bin dir (`c:\tools\neovim\Neovim\bin`) to your System or User PATH variable.

```ps1
# Install neovim package with nvim.exe and nvim-qt.exe
choco install neovim -y
```

### `Neovim\bin` path in your System PATH Variable
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


### fzf.vim and fzf

`fzf` is a is a cross-platform "fuzzy finder" that takes a list of entries and provides "fuzzy" filtering based on partial matches. It lets you quickly filter to filename you "kind of" remember a ways down.

#### Bindings

  * `CTRL-T`/`CTRL-X`/`CTRL-V`: Open in new tab/split/vsplit
  * `:FzfSomeCommand!`: Fullscreen version of Fzf commands
  * `:FZF`: Open fzf to the current directory (default)
  * `<C-x><C-k>`: Dictionary word complete

#### Customizations

  * `:Fzf<command>`: Prefix for all commands. Custom, in order to locate fzf specific functions easily.

#### Other

An `g:fzf_action` exists to configure bindings in addition to the default `CTRL-T`, `CTRL-X`, and `CTRL-V` versions.


#### junegunn/fzf
[junegunn/fzf](https://github.com/junegunn/fzf) adds basic fzf bindings to vim. 

The `fzf` binary must exist in the system path. One method is to install the package to your operating system.

  * Windows: `choco install fzf -y`
  * macOS: `brew install fzf`

Alternatively, `junegun/fzf` plugin *is* the `fzf` source code. The plugin's `/bin` directory is included in the search path as well. On a POSIX system, you can include the plugin in your [`init.vim`](init.vim) with an included install command. 

```viml
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
```

It's unknown if a similar automation style is available on Windows.

#### junegunn/fzf.vim
Adds vim specific functions to [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim). This is the thing we customize.
