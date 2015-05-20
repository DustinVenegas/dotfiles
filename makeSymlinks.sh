#!/bin/bash
############################
# Create symlinks from ~/dotFiles to ~/.{expected}
############################

ln -s ~/dotFiles/.vimrc ~/.vimrc
ln -s ~/dotFiles/.vim ~/.vim

# Install vundle on new systems
git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
