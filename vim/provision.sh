#!/bin/bash

# Symlink directory to ~/.vim/
DOTFILES_VIM_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
VIM_CONFIG_DIR='~/.vim'
if [ ! -L ~/.vim ]; then
  ln -s "$DOTFILES_VIM_DIR" "$VIM_CONFIG_DIR"
fi

# Install vim-plug plugins.
vim +PlugInstall +qall