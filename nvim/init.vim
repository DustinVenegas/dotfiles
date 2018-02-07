" vim:foldmethod=marker:foldlevel=100

" Plugins {{{
call plug#begin()

    " Color schemes {{{
    Plug 'altercation/vim-colors-solarized'
    Plug 'jonathanfilip/vim-lucius'
    Plug 'jnurmine/Zenburn'
    " }}}
    
    Plug 'airblade/vim-gitgutter'

    Plug 'junegunn/fzf.vim' " Fuzzy funder; depends on fzf pkg via choco or brew

call plug#end()
" }}}


" Color schemes/themes {{{
set termguicolors " Use 24-bit, modern terminal, escape codes for commands
set background=dark " Seattle? Dark. Not too dark. Just dark.

if globpath(&runtimepath, 'colors/lucius.vim', 1) != ''
    colorscheme lucius " Flavor of the week
endif
" }}}


" General {{{
set clipboard+=unnamedplus " Use sys-clipboard, instead of '*','+' registers 
set tabstop=4 " Tabs count for X spaces
set shiftwidth=4 " Indent operations shift X spaces
set softtabstop=-1 " Use {shiftwidth} for value. Allows {tabstop} to stay at 8
                   " There's somethig 
set expandtab " Tabs count for {tabstop} spaces
                   " CTRL-V<Tab> - Insert an actual tab character
set ignorecase " Searches ignore case. w/smartcase, only all lower-case searches
set smartcase " w/ignorecase opt, case sensitive on mixed case searches
set showmatch " Highlight matching brackets as you cursor over them
set number " Turn on line numbers
set wrap! " Line wrapping off
" }}}


" netrw, built-in networking file browser, and regular one too {{{
let g:netrq_liststyle=3 " netrw should display as a tree by default
" }}}


" Key Mappings and Shortcuts {{{
tnoremap <Esc> <C-\><C-n> 		" Ensure ESC also escapes in :terminal mode

" Remap alt+vim_direction_key to switch splits/windows in any mode!
tnoremap <A-h> <C-\><C-N><C-w>h
tnoremap <A-j> <C-\><C-N><C-w>j
tnoremap <A-k> <C-\><C-N><C-w>k
tnoremap <A-l> <C-\><C-N><C-w>l
inoremap <A-h> <C-\><C-N><C-w>h
inoremap <A-j> <C-\><C-N><C-w>j
inoremap <A-k> <C-\><C-N><C-w>k
inoremap <A-l> <C-\><C-N><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l
" }}}
