" vim:foldmethod=marker:foldlevel=100

" Plugins {{{
call plug#begin()

    " Color schemes {{{
    Plug 'altercation/vim-colors-solarized'
    Plug 'jonathanfilip/vim-lucius'
    Plug 'jnurmine/Zenburn'
    " }}}

    Plug 'airblade/vim-gitgutter' " Shows git diff markers in gutter
    Plug 'tpope/vim-fugitive' " Git commands as G* Ex commands

    Plug 'mileszs/ack.vim' " grepprg replacement using vim's quickfix list
                           " backed by grep, ack, ripgrep, ag, etc
                           " SEE `:help ack.txt`

    Plug 'junegunn/fzf' " Required for fzf.vim
    Plug 'junegunn/fzf.vim' " fzf fuzzy finder, or way to quickly filter

    Plug 'editorconfig/editorconfig-vim' " Respect .editorconfig files - http://editorconfig.org/

call plug#end()
" }}}


" mileszs/ack.vim {{{

" Avoid errosr on Windows by turning off gitgutter grep by default
let g:gitgutter_grep=''

if executable('grep')
    " Use Grep for :Ack commands, since it exists
    let g:gitgutter_grep='grep'
    set grepprg='grep'
endif

if executable('rg')
    " Use RipGrep (rg) for :Ack commands
    let g:ackprg='rg --vimgrep'
    set grepprg='rg'
    let g:gitgutter_grep='rg'
endif

" }}}


" editorconfig/editorconfig-vim {{{

" Ignore .editorconfig rules for the following wildcarded array:
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

" }}}

" Color schemes/themes {{{
set termguicolors " Use 24-bit, modern terminal, escape codes for commands
set background=dark " Seattle? Dark. Not too dark. Just dark.

if globpath(&runtimepath, 'colors/lucius.vim', 1) != ''
    colorscheme lucius " Flavor of the week

    if !empty($CONEMUBUILD)
        " ConEmu should use LuciusBlack to get around terminal color issues
        LuciusBlack
    endif
endif
" }}}


" General {{{
set clipboard+=unnamedplus " Use sys-clipboard, instead of '*','+' registers
set tabstop=4 " Tabs count for X spaces
set shiftwidth=4 " Indent operations shift X spaces
set softtabstop=-1 " Use {shiftwidth} for value. Allows {tabstop} to stay at 8
set expandtab " Tabs count for {tabstop} spaces
                   " CTRL-V<Tab> - Insert an actual tab character
set ignorecase " Searches ignore case. w/smartcase, only all lower-case searches
set smartcase " w/ignorecase opt, case sensitive on mixed case searches
set showmatch " Highlight matching brackets as you cursor over them
set number " Turn on line numbers
set wrap! " Line wrapping off
" }}}


" Plugin: fzf.vim {{{

let g:fzf_command_prefix = 'Fzf' " Prefixes all fzf commands with Fzf
                                 " Allows tab to easily locate commands

" e.g. Replaces word completion with fzf version
"inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'left': '15%'})

" }}}


" Plugin: vim-fugitive {{{

    " (:Gstatus based)
    nnoremap <Leader>g?     :help fugitive<CR>
    nnoremap <Leader>g<CR>  :Gedit<CR>

    " git commit (:Gstatus based)
    nnoremap <Leader>gcA    :Gcommit --amend --reuse-message=HEAD
    nnoremap <Leader>gca    :Gcommit --amend
    nnoremap <Leader>gcva   :Gcommit --amend --verbose
    nnoremap <Leader>gcc    :Gcommit
    nnoremap <Leader>gcvc   :Gcommit --verbose

    " git diff (:Gstatus based)
    nnoremap <Leader>gD     :Gdiff<CR>
    nnoremap <Leader>gds    :Gsdiff<CR>
    nnoremap <Leader>gdv    :Gvdiff<CR>

    nnoremap <Leader>gpa    :Git add --patch
    nnoremap <Leader>gpr    :Git reset --patch

    " status
    nnoremap <Leader>gs     :Gstatus<CR>

    " Misc
    nnoremap <Leader>gl     :silent! Glog<CR>:bot copen<CR>
    nnoremap <Leader>gb     :Gblame<CR>
    nnoremap <Leader>gB     :Gbrowse<CR>
    nnoremap <Leader>ge     :Gedit<CR>
    nnoremap <Leader>gM     :Gmove<Space>
" }}}


" Key Mappings and Shortcuts {{{
tnoremap <Esc> <C-\><C-n> 		" Ensure ESC also escapes in :terminal mode

" alt+(hjkl): Maps A+hjkl in terminal/insert/normal
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


augroup filetype_markdown
    autocmd!
    " Turn spell check on for the buffer
    autocmd BufNewFile,BufRead *.md setlocal spell
    autocmd BufNewFile,BufRead *.rdoc setlocal spell
augroup END
