# neovim

[Neovim](https://www.neovim.io/) modal editor configuration. 

Expects to be [source](https://neovim.io/doc/user/repeat.html#:source) loaded from the appropriate [`XGD_BASE_DIR`](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) (Windows: `~/AppData/Local/nvim/init.vim`, Linux: `~/.config/nvim/init.vim`). 

**`init.vim`**
Set `runtimepath` to this repository. [`source`](https://neovim.io/doc/user/repeat.html#:source) our `init.vim` (TODO: are both necessary?). 

```viml
" 
set runtimepath^=~/dotfiles/nvim./
source ~\dotfiles\nvim\init.vim
```

## Plugins

[junegunn/vim-plug](https://github.com/junegunn/vim-plug) is used to manage neovim plugins. It was selected for its simplicity.

**Maintenance** `:PlugUpgrade` updates [`~/dotfiles/nvim/autoload/plug.vim`](./autoload/plug.vim) to the latest vim-plug version. Commit the changes to your dotfiles repository.

