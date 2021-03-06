# neovim

[Neovim](https://www.neovim.io/) editor configuration for Dustin Venegas.

## Useful Shortcuts

Turning `spell` on means the following commands will work...

* `]s` and `[s` motions for next and previous mistakes.
* `zg`, `zG` add **good** word spellings to spellfile, internal-wordlist
* `zw`, `zW` add **wrong** word spellings to spellfile, internal-wordlist
* `zu`, `zU` clears good and wrong word spellings from spellfile, internal-wordlist

## Install

These instructions are based on the [Neovim Installation Instructions](https://github.com/neovim/neovim/wiki/Installing-Neovim).

### Chocolatey

[Chocolatey](https://chocolatey.org/) is a great installation method for Windows.
All packages are listed in [`chocolatey-packages.config`](./chocolatey-packages.config)
and can be installed with the following Powershell, from an elevated
(Administrator) console.

```ps1
# In an elevated (Administrator) PowerShell Consone. Use `csudo` on ConEmu!

# Change directories to where we usually check out dotfiles
cd $HOME/dotfiles/nvim/

# Chocolatey, install packages in the config with automatic confirmation
choco install chocolatey-packages.config -y
```

#### System PATH and the neovim Chocolatey Package

**NOTE!** Add `neovim.exe` and `neovim-qt.exe` to your System PATH variable

The nvim Chocolatey package comes with `neovim.exe` and `neovim-qt.exe`. The
installer does not add these to the system PATH.

```ps1
# Check the current path. Current entries with "neovim" are printed.
$userEnvVars = [System.Environment]::GetEnvironmentVariable("PATH", "User")
$userEnvVars -Split ';' | Where-Object { $_ -like '*Neovim\bin*' }

# set a variable pointing at your neovim directory
$neovimPath = 'C:\tools\neovim\Neovim\bin'

# AS ADMIN, appends $neovimPath variable contents to system PATH variable
[Environment]::SetEnvironmentVariable("PATH", "$($userEnvVars);$neovimPath", "User")
```

Confirm by opening up a *new* shell, typing `nvim-qt.exe`, and pressing enter.

### node.js Support

Install node.js project dependencies. These dependencies sit in the
`node_modules` folder next to this project.

```sh
# Install the dependencies
cd ~/dotfiles/nvim/
npm install
```

### Python Support

The [`chocolatey-packages`](chocolatey-packages.config) bundle should include
`python2` and `python3`. You can install them directly using:

```powershell
choco install 'python2;python3' -y
```

These packages come with `python`, `pip2` and `pip3`. They are not added to the
system PATH, and need to be added by hand.

```ps1
# Check the current path. Current entries with "neovim" are printed.
$userEnvVars = [System.Environment]::GetEnvironmentVariable("PATH", "User")
$userEnvVars -Split ';' | Where-Object { $_ -like '*python*' }

# set a variable pointing at your neovim directory
$neovimPath = 'C:\tools\neovim\Neovim\bin'

# AS ADMIN, appends $neovimPath variable contents to system PATH variable
[Environment]::SetEnvironmentVariable("PATH", "$($userEnvVars);$neovimPath", "User")
```

#### Virtual Environment

Python recommends [`pipenv`](https://github.com/pypa/pipenv) for creating a
Python Virtual Environment. This prevents collisions and resolutions between
Neovim and your global python library. `pipenv` also manages `pipfiles`
dependencies, which makes maintenance straightforward.

A `pipfile` exists for each neovim Python environment under
[`python-envs/`](python-envs/). Running `pipenv -py` with a `pipfile` in the
current working directory returns the _actual_ `python` binary location.

First, we need to install the `pipenv` program for python2 and python3.

```ps1
# From any directory. pipenv can create/manage python deps and venvs
pip3 install --upgrade pipenv
pip2 install --upgrade pipenv
```

Next, use `pipenv` to install the latest dependencies and setup a virtual
environment. Finally, we print the actual python executable path.

```bash
# setup base python 2.7 virtualenv
pushd nvim/python-venvs/2.7/
pipenv install
pipenv --py
popd

# setup base python 3.7 virtualenv
pushd nvim/python-venvs/3.7/
pipenv install
pipenv --py
popd
```

Finally, edit your machine's `init.vim` (not the dotfiles one) using Ex command
`:edit $MYVIMRC`. Specify **both** python executables **before** it source loads
this dotfiles repository's[`init.vim`](init.vim).

```viml
" Maps to dotfiles virtualenv versions for neovim using pipenv
" See: ~/dotfiles/nvim/README.md#virtual-environment
" MUST APPEAR BEFORE dotfiles/nvim/init.vim is source loaded
let g:python3_host_prog='C:\Users\dusti\.virtualenvs\3.7-LFOTLC8X\Scripts\python.exe'
let g:python_host_prog='C:\Users\dusti\.virtualenvs\2.7-8oiZRLVE\Scripts\python.exe'

" Autogenerated by provision.ps1 on FAKE, I write this by hand...
" Set our dotfiles/nvim/ directory as the first runtimepath to check for files
set runtimepath^=~/dotfiles/nvim/

" Source the dotfiles init.vim
source ~/dotfiles/nvim/init.vim
```

##### Creating and Modifying Virtual Environments

Keep these in mind when creating or modifying the python `virtualenv`,
`pipfile`, or `pipenv` components:

    * Each folder under `python-venvs` should represent an environment and
      contain a `Pipfile`
    * Each `Pipfile` contains the python dependencies, specifically for neovim,
      for the virtual environment
    * Each python environment must include the `neovim` module

```ps1
# Uncomment to create a new virtualenv directory, if adding an entirely new virtualenv
# New-Item -type Directory python-venvs/my-special-version/

# Change directories to the version
cd python-venvs/my-special-version

# Bootstrap a new virtualenv, create a pipfile, and specify a python version.
# 2.7 represents the version number of python to use.
pipenv --python 2.7

# Up-stall-grade neovim for python2
pip2 install --upgrade neovim
```

Check your neovim python health with the following Ex command:

```viml
:CheckHealth
```

### Source from `init.vim`

This dotfiles configuration expects to be [source](https://neovim.io/doc/user/repeat.html#:source)
loaded from the appropriate [`XGD_BASE_DIR`](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)

    - Windows: `~/AppData/Local/nvim/init.vim`
    - Linux: `~/.config/nvim/init.vim`

Below is an example `init.vim` file which uses the default checkout location on
a Windows machine.

```viml
" Add our git dotfiles checkout to neovim's rtp for loading scripts
set runtimepath^=~/dotfiles/nvim/

" Load our configuration
source ~/dotfiles/nvim/init.vim
```

_Note,_ Source loading the dotfiles configuration has pros and cons. Some
operating systems don't posses full symlinking capabilities. Consistently source
loading across all operating systems just makes things easier.

## Plugins

This configuration is intended to gracefully handle missing plugins, themes, and
fonts. vim-plug is a hard dependency and is therefore committed directly to the
repository. You'll need to run `:PlugInstall` in short order to load plugins,
themes, etc.

Why do we take a hard dependency on vim-plug, but ignore the plugin submodules?
Some plugins have different platform requirements. They've been for Windows
compatibility in the past. While not ideal for consistency, this has been
sufficient for my needs.

**Note,** if you try to execute `nvim-qt.exe` and a window opens but never
really loads then there might be a missing configuration issue. Run `nvim.exe`
to ensure there are no configuration errors. You may have to run `:PlugInstall`
using the command-line version, `nvim.exe`.

### vim-plug

[junegunn/vim-plug](https://github.com/junegunn/vim-plug) is used to manage
neovim plugins. It was selected for its simplicity.

    * `:PlugInstall` installs defined plugins
    * `:PlugDiff` shows a diff of incoming changes
    * `:PlugUpdate` updates all plugins
    * `:PlugUpgrade` updates [`~/dotfiles/nvim/autoload/plug.vim`](./autoload/plug.vim)
      to the latest vim-plug version. Verify changes, then commit updates to this
      repository.

### vim-gitgutter

[airblade/vim-gitgutter](https://github.com/airblade/vim-gitgutter) adds markers
to the gutter that indicate if lines were added, modified, or removed in git.

* `:GitGutterToggle` toggles the feature on/off
* `]c`, `[c`, goes to next and previous hunks

### junegunn/fzf

[junegunn/fzf](https://github.com/junegunn/fzf) is both the `fzf` source code
and basic vim bindings for `fzf`.  `fzf` is a cross-platform "fuzzy finder". It
takes lists and provides "fuzzy" filtering based on partial or near matches.

This plugin depends on the `fzf` binary in your PATH. It adds the `FZF` ex-mode
command to vim.

* `:FZF`: Open fzf to the current directory (default)

### aklt/plantuml-syntax

[aklt/plantuml-syntax](https://github.com/aklt/plantuml-syntax) adds syntax
highlighting and a `make` command for PlantUML diagrams that end in `.uml`.

### tyru/open-browser.vim

Installed as a depndency of `weirongxu/plantuml-previewer.vim`.

* `:openbrowser#*` commands, such as `:openbrowswer#open()` to open in the
  default browser.

### weirongxu/plantuml-previewer.vim

Depends on `tyru/open-browser.vim` and `aklt/plantuml-syntax`.

* `:PlantumlOpen` to start a web site watching the output from the current file

#### External Dependencies

You can install `fzf` using a package manager.

* Windows: `choco install fzf -y`
* macOS: `brew install fzf`

Alternatively, the `junegun/fzf` plugin directory *is* the `fzf` source code.
The `/bin` directory is already included in the search path. On a POSIX system,
you could use a vim-plug "after" command to build `fzf`.

```viml
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
```

Windows would need to take on additional dependencies to perform the same
installation style. This dotfiles repository prefers a manual installation due
to differing commands on Windows and Linux.

### junegunn/fzf.vim

[junegunn/fzf.vim](https://github.com/junegunn/fzf.vim) contains vim-specific
`fzf` bindings. This is the thing we customize in vim.

An `g:fzf_action` exists to configure bindings in addition to the default
`CTRL-T`, `CTRL-X`, and `CTRL-V` versions.

#### junegunn/fzf.vim Bindings

* `CTRL-T`/`CTRL-X`/`CTRL-V`: Open in new tab/split/vsplit
* `:FzfSomeCommand!`: Full screen version of Fzf commands
* `<C-x><C-k>`: Dictionary word complete

#### junegunn/fzf.vim Customizations

* `:Fzf<command>`: Prefix for all commands. Custom, in order to locate fzf
  specific functions easily.
* `<Leader>ff` find files from cwd
* `<Leader>fF` find files from current buffer's directory

#### junegunn/fzf.vim Issues

* (Windows) `fzf#vim#with_preview` uses a Ruby script that requires additional
  tools to function on Windows. The script is located at `dotfiles\nvim\plugged\fzf.vim\bin\preview.rb`.

### editorconfig/editorconfig-vim

[editorconfig/editorconfig-vim](https://github.com/editorconfig/editorconfig-vim)
provides validation and auto-formatting for [EditorConfig](http://editorconfig.org/)
styles.

* `:EditorConfigReload`: reload `.editorconfig` files for the current file edited

### tpope/vim-fugitive

[tpope/vim-fugitive](https://github.com/tpope/vim-fugitive) adds git Ex
Commands, Windows, etc inside of neovim. It provides additional methods to
interface with git through vim without using `!bang` Ex Commands or the
`:terminal`. It's useful _in addition_ to git's CLI; not as a replacement.

fugitive, and Tim Pope in general, don't make drawer-style plugins. Instead of
creating fixed Windows and Viewports the user is expected to manage the
vim-fugitive windows.

Opening new buffers for commands is the first methodology. Manually manage them
using `<C-W>*` bindings, such as `<C-W><C-C>` to close a window. Get creative
with buffers! Tim Pope recommends `<C-W><C-O>` to close all buffers except the
currently active one.

Changing the active buffer and returning with ':Gedit' is the other methodology.
Commands like `glog` will open a RO buffer in your active window. You'll have to
use a `:Gedit` variation in order to return to actually editing the file.

#### vim-fugitive Bindings

* `Gedit`, `Gsplit`, `Gvsplit` edits a revision, splits a revision, virt-splits
  a version
* `:Git [args]` runs a `git` command (w/params) relative to the repository root
* `:Glcd`, `:Gcd` changes directory of the local buffer, or project directory,
  relative to the repository root
* `:Glog` loads previous revisions of the active buffer file as RO buffers,
  replacing the active buffer. Use `:cnext` and `:cprev` to navigate revisions.
  Afterward, use a `Gedit` variation to continue editing the original buffer.
* `:Gstatus` displays `git status` output
    * `-` adds and resets (stages/un-stages) files
    * `ca` performs `Gcommit --amend` on the file selected
    * `<C-N>`, `<C-P>` next and previous file
    * `D` performs a `Gdiff` against the file selected
    * `p` performs `:Git add --patch`
    * `q` closes status
    * `r` reload status
    * `U` checkout
    * `C` switches the buffer to a commit dialog
* `:Gcommit` opens a buffer asking for a commit message at `.git/COMMIT_EDITMSG`
* `:Gwrite` will commit files with the log message specified
* `:G<git-command>` invokes the git command specified. For example, pull, push,
  fetch, log, llog, etc

#### vim-fugitive Customizations

// TODO: Determine how to sync bindings.

### 'ripgrep'

[BurntSushi/ripgrep](https://github.com/BurntSushi/ripgrep), AKA `rg`, is a
cross-platform, very fast, alternative to ack/grep.

Why ripgrep over ack, grep, ag (The Silver Searcher), etc? It makes `:grep` work
cross-platform. It's really fast. It respects .gitignore files. Swank name.

#### Prerequisites

Run `choco install chocolatey-packages.config` or `choco install ripgrep -y`
directory to install on Windows. Chocolatey should create a ShimGen in
`C:\ProgramData\chocolatey\bin\rg.exe`, which should be in your machine's PATH.
The binary should be located at
`C:\ProgramData\chocolatey\lib\ripgrep\tools\rg.exe`.

Configurations attempt to detect the existence of RipGrep and use it as the
default where appropriate. For example, below are some of the items that prefer
Ripgrep if it's available:

* Sets `grepprg` for `:grep` searches in vim
* Configures `mileszs/ack.vim` for `:Ack` searches
* `fzf` should use rg by default
* `fzf` in PowerShell should prefer Ripgrep
* Probably others

#### ripgrep Configuration

Always use a specific ripgrep configuration file?

`local.dotfiles.json` can specify `g:ripgrep_config` to the fully-expanded
`~/.ripgreprc` path.

#### ripgrep Bindings

* `-uuu` removes search restrictions, up to 3. One includes `.gitignore`
  entries, two searches hidden, three locates binaries
* `rg -S SmartCaseSearch` performs a smart case search

### 'mileszs/ack.vim'

[mileszs/ack.vim](https://github.com/mileszs/ack.vim) adds the `:Ack` Ex command
to perform an "ack-like search".

Behind the scenes the tool to search in file contents may be one of many
including ack, [RipGrep, `rg`](https://github.com/BurntSushi/ripgrep), and [The
Silver Searcher, `ag`](https://github.com/ggreer/the_silver_searcher)
, or others. Setup to prefer `rg`, over `ag`, over `<default>`.

Uses the `:help quicklist` and `:help locationlist` for search results. See
`:help ack.txt` for more information.

### 'aklt/plantuml-syntax'

[aklt/plantuml-syntax](https://github.com/aklt/plantuml-syntax) adds syntax for
`*.puml` files, or buffers with `:set filetype=plantuml`

* Sets `makeprg=plantuml` for calls for `:make`
* No help available

### 'hashivim/vim-terraform'

[hashivim/vim-terraform](https://github.com/hashivim/vim-terraform) adds
file-type and basic syntax support for
[Terraform](http://terraform.io/).

* Adds `:Terraform` command.
* Format on save is turned ON.

### 'w0rp/ale'

[w0rp/ale](https://github.com/w0rp/ale) is an Asynchronous Lint Engine for Vim.
This extension provides syntax checking without blocking Vim by acting as a
Language Server Protocol client.


#### Configuration

The ale extension can use external linters, fixers, etc. These tools need to be
installed and available to Vim via the configured virtual environments. For
example, in order to use eslint as a fixer, the application must have already
been installed and available to the PATH by using `npm install -g eslint`, or
available to the node.js virtual environment configured for Vim.

##### Linters

* JavaScript
    * [Flow](https://flow.org/) `npm install -g flow`
* Markdown
    * markdownlint via [markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli)
      `npm install -g markdownlint-cli`

### 'justinml/vim-dirvish'

[vim/dirvish](https://github.com/justinmk/vim-dirvish) is a file browser written
in VimL. Netrw, vim's built-in file browser, is slow and buggy.

* Adds `:Dirvish` command.
* Buffers set environment variables, yank, etc so that `@%` and `@#` are the
  directory and filename in many cases.

### 'kristijanhusak/vim-dirvish-git'

[kristijanhusak/vim-dirvish-git](https://github.com/kristijanhusak/vim-dirvish-git)
extends the `justinml/vim-dirvish` file browser with Git status icons.

* `]f`, `[f` jumps to the next, previous Git file.

### Syntax Plugins

* [PProvost/vim-ps1](https://github.com/PProvost/vim-ps1) adds support for
  PowerShell syntax.
* [docker/docker](https://github.com/docker/docker) is the Docker Moby project
  and includes syntax support for Dockerfiles.
