# neovim

[Neovim](https://www.neovim.io/) modal editor configuration for Dustin Venegas. 


## Setup


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


### vim-plug

[junegunn/vim-plug](https://github.com/junegunn/vim-plug) is used to manage neovim plugins. It was selected for its simplicity. 

  * `:PlugInstall` installs the plugins defined.
  * `:PlugUpgrade` updates [`~/dotfiles/nvim/autoload/plug.vim`](./autoload/plug.vim) to the latest vim-plug version. After verifying the changes, they can be committed to the dotfiles repository for distribution.


### vim-gitgutter
[airblade/vim-gitgutter](https://github.com/airblade/vim-gitgutter) adds markers to the gutter that indicate if lines were added, modified, or removed in git. 

  * `:GitGutterToggle` toggles the feature on/off
  * `]c`, `[c`, goes to next and previous hunks


### fzf.vim and fzf

[junegunn/fzf](https://github.com/junegunn/fzf) is a "fuzzy finder" for multiple operating systems without other dependencies. In short, it lists a whole bunch of files and lets you drill down based on fuzzy matching of the filenames. 

In conjunction with [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim), the fuzzy finder can be used in Neovim for opening files and searching code.
