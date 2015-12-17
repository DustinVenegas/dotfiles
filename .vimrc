""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"   Filename: .vimrc                                                           "
" Maintainer: Dustin Venegas <dustin.venegas@gmail.com>                        "
"        URL: https://github.com/DustinVenegas/dotfiles                        "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Environment Specific Setup {
    set nocompatible " Make Vim behave in a more useful way

    " Environment
    if has('win32') || has('win64')
        behave mswin
    endif
" }

set runtimepath+=~/dotfiles/.vim/autoload

" Plugged {
    call plug#begin('~/dotfiles/.vim/plugged')
    
    " File explorer
    Plug 'scrooloose/nerdtree'

    " git Support
    Plug 'tpope/vim-fugitive'
    
    " Syntax support for PowerShell
    Plug 'PProvost/vim-ps1'
    
    " Syntax support for CoffeeScript
    Plug 'kchmck/vim-coffee-script'
    
    " Color Sceme named Zenburn
    Plug 'jnurmine/Zenburn'

    " Color Scheme named Solarized
    Plug 'altercation/vim-colors-solarized'
    
    " matrix screen for fun and profit
    Plug 'vim-scripts/matrix.vim--Yang'

    " TagBar for ctags support
    Plug 'majutsushi/tagbar'

    call plug#end()
" }


" Vim Options {
    filetype plugin indent on " load filetype plugins/indent settings
    set encoding=utf-8 " Default to UTF-8 instead of Latin-1
    set autochdir " Switch to the current file's directory
    set backspace=indent,eol,start " Allow backspacing over everything in insert mode
    set history=100 " # of command history lines to save
    set ignorecase " Case insensitive search
    set incsearch " Find crap as I type
    set noerrorbells " Stop beeping Johnny Five
    set smartcase " Case sensitive search if contains upper case
    set ttyfast " We're not on dial-up anymore. Send more data over the network.
    set clipboard=unnamed " Use the OS clipboard

    " Hate on backups and swap files
    set nobackup " do not keep backups after close
    set nowritebackup " do not keep a backup while working
    set noswapfile " don't keep swp files either

    " Set backup directory to my tmp folder
    set backupdir=$TEMP//

    " Make swap live in tmp folder with the backup
    set directory=$TEMP//

    syntax on " Turn syntax highing on
    filetype on " Try to detect filetypes

    " Let the omni complete guess based on filetype
    au FileType cs set omnifunc=syntaxcomplete#Complete
    au FIleType python set omnifunc=pythoncomplete#Complete
" }

" Editor {
    " Theme
    set background=dark
    colorscheme solarized

    set autoindent "Auto indenting
    set cul " Set cursor line
    set cursorcolumn " highlight the current column
    set cursorline " highlight current line
    set expandtab " Make sure tabs turn in to spaces
    set hlsearch " Highlight searches
    set laststatus=2 " always show the status line
    set listchars=tab:>-,trail:- "Show tabs and tailing
    set number " Turn on line numbers
    set ruler "always show current positions along the bottom
    set shiftwidth=4 " Shifts are 4 columns
    set showcmd " Show what you are typing as a command
    set showmatch " show matching brackets
    set smarttab " insert blanks in front of lines when tab is pressed
    set softtabstop=4 " Tabs are 4 columns
    "set spell " Spell checking on
    set statusline=%F%m%r%h%w%{fugitive#statusline()}[FORMAT=%{&ff}][TYPE=%Y][ASCII=\%03.3b][HEX=\%02.2B][POS=%04l,%04v][%p%%][LEN=%L]
    set tabstop=4 " Tabs are 4 columns
    set wildmenu
    set wildmode=list:longest,full
    set wrap! " Turn off wrapping by default

    highlight Error gui=undercurl
" }

" Gui {
    if has("gui_running")
        set columns=100 " 100 columns

        " Select fonts based on environment
        if has('win32') || has('win64')
            set guifont=consolas:h10
        else
            set guifont=dejavu\ sans\ mono\ 10
        endif

        set guioptions=ce
        "              ||
        "              |+-- Simple dialogs instead of popups
        "              +--- Use GUI tabs
        set mousehide " Hide the mouse curosr when typing
    endif
" }

 " Folding {
     set foldenable " Turn on folding
     set foldmarker={,} " Fold C style code (only use this as default
                        " if you use a high foldlevel)
     set foldmethod=marker " Fold on the marker
     set foldlevel=100 " Don't autofold anything (but I can still fold manually)
     set foldopen=block,hor,mark,percent,quickfix,tag " what movements open folds
     function SimpleFoldText()
         return getline(v:foldstart).' '
     endfunction
     set foldtext=SimpleFoldText() " Custom fold text function (cleaner than default)
 " }

" Plugin settings {
    " TagBar { 
        let g:tagbar_type_ps1 = {
            \ 'ctagstype' : 'powershell',
            \ 'kinds'     : [
                \ 'f:function',
                \ 'i:filter',
                \ 'a:alias'
            \ ]
        \ }

        let g:tagbar_type_coffee = {
            \ 'ctagstype' : 'coffee',
            \ 'kinds'     : [
                \ 'c:classes',
                \ 'm:methods',
                \ 'f:functions',
                \ 'v:variables',
                \ 'f:fields',
            \ ]
        \ }
    " }
" }

" Language Specific Settings {
    " Coffeescript tabtop at 2 spaces
    autocmd BufNewFile,BufReadPost *.coffee setl shiftwidth=2 expandtab
" }

" Key Mappings {
    "map <F12> ggVGg? " ROT13 - fun
    map Q gq " Q -> Formatting instead of Ex mode
    inoremap <C-U> <C-G>u<C-U>  " CTRL-U in ins deletes a lot. Use CTRL-G to break into undo first.
    "
    " space / shift-space scroll in normal mode
    noremap <S-space> <C-b>
    noremap <space> <C-f>

    " Make Arrow Keys Useful Again
"    map <up> <ESC>:Tlist<RETURN>
    map <down> <ESC>:NERDTreeToggle<RETURN>
    map <left> <ESC>:Matrix<RETURN>
"    map <right> <ESC>:Matrix<RETURN>

    " Ctrl MOdifiers
    map <C-left> <ESC>:bp<RETURN>
    map <C-right> <ESC>:bn<RETURN>

    nnoremap <silent> <F2> :TagbarToggle<CR>
" }

" Shell {
if has("win32") || has("gui_win32")
    "
    "if executable("PowerShell")
    "    " Set PowerShell as the shell for running external ! commands
    "    " http://stackoverflow.com/questions/7605917/system-with-powershell-in-vim
    "    set shell=PowerShell
    "    set shellcmdflag=-ExecutionPolicy\ RemoteSigned\ -Command
    "    set shellquote=\"
    "    " shellxquote must be a literal space character.
    "    set shellxquote= 
    "  endif
endif
" }

function MyDiff()
   let opt = '-a --binary '
   if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
   if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
   let arg1 = v:fname_in
   if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
   let arg2 = v:fname_new
   if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
   let arg3 = v:fname_out
   if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
   if $VIMRUNTIME =~ ' '
     if &sh =~ '\<cmd'
       if empty(&shellxquote)
         let l:shxq_sav = ''
         set shellxquote&
       endif
       let cmd = '"' . $VIMRUNTIME . '\diff"'
     else
       let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
     endif
   else
     let cmd = $VIMRUNTIME . '\diff'
   endif
   silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
   if exists('l:shxq_sav')
     let &shellxquote=l:shxq_sav
   endif
endfunction
set diffexpr=MyDiff()

" ex command for toggling hex mode - define mapping if desired
command -bar Hexmode call ToggleHex()

" helper function to toggle hex mode
function ToggleHex()
    " hex mode should be considered a read-only operation
    " save values for modified and read-only for restoration later,
    " and clear the read-only flag for now
    let l:modified=&mod
    let l:oldreadonly=&readonly
    let &readonly=0
    let l:oldmodifiable=&modifiable
    let &modifiable=1
    if !exists("b:editHex") || !b:editHex
        " save old options
        let b:oldft=&ft
        let b:oldbin=&bin

        " set new options
        setlocal binary " make sure it overrides any textwidth, etc.
        let &ft="xxd"

        " set status
        let b:editHex=1

        " switch to hex editor
        %!xxd
    else
        " restore old options
        let &ft=b:oldft
        if !b:oldbin
            setlocal nobinary
        endif
        " set status
        let b:editHex=0

        " return to normal editing
        %!xxd -r
    endif

    " restore values for modified and read only state
    let &mod=l:modified
    let &readonly=l:oldreadonly
    let &modifiable=l:oldmodifiable
endfunction

function FindNonAscii()
    " Locate all characters lying outside the ASCII range. Decimal alternative
    " is [^\d0-\d127]
    syntax match nonascii "[^\x00-\x7F]"
    highlight nonascii guibg=Red ctermbg=2 termbg=2
endfunction

" Allow overrides {
    if filereadable(expand("~/.vimrc.local"))
        source ~/.vimrc.local
    endif
" }

" Influences {
"    http://www.vi-improved.org/vimrc.html
"    https://github.com/dougireton/vimfiles
" }
