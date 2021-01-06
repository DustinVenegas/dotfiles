" SYNOPSIS
"   Configures vim to use a configuration at $HOME/.vim/.vimrc so
"   a vim loads the same directories on Windows and Linux.
" DESCRIPTION
"   _vimrc can be used on Microsoft Windows to load an underlying configuration
"   at $HOME/.vim/. This file should be symlinked to $HOME/_vimrc or $HOME/.vimrc
"   when using vim on Microsoft Windows.
" NOTES
"   vim uses different configuration paths on Windows and Unix, as of 07/2020 Vim 8.2:
"     - On Unix,      $HOME/.vim exists     in RTP and $HOME/.vim/.vimrc is sourced
"     - On Microsoft, $HOME/vimfiles exists in RTP and $HOME/_vimrc      is sourced

if has('win32') || has('win64')
    set runtimepath^=~\\.vim
    set runtimepath+=~\\.vim\\after

    source $HOME\\.vim\\.vimrc
else
    source $HOME/.vim/.vimrc
endif
