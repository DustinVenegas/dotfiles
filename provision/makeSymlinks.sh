#!/bin/bash
############################
# Create symlinks from ~/dotFiles to ~/.{expected}
############################

if [ ! -l ~/.vimrc ]; then
  ln -s ~/dotfiles/.vimrc ~/.vimrc
fi

if [ ! -L ~/.vim ]; then
  ln -s ~/dotfiles/.vim ~/.vim
fi

vim +PlugInstall +qall

# Configure git
./git-config-commands

# Configure git for OSX
./git-config-commands-osx
