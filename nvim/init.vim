" vim:foldmethod=marker:foldlevel=100

" Local settings files {{{
function! s:IncludeDotfilesVim()
    " Includes the local.dotfiles.vim from the rtp
    if !empty(globpath(&rtp, 'local.dotfiles.vim'))
        " Source all instances of local.settings.vim in the &rtp
        " TODO: Keep or ditch? I like the idea of json if
        runtime! 'local.dotfiles.vim'
    endif
endfunction

function! s:IncludeDotfilesJson()
    " Includes (sets) settings from local.dotfiles.json from the rtp
    let localDfSettings = globpath(&rtp, 'local.dotfiles.json')
    if !empty(localDfSettings)
        "echomsg 'DF: Using local configuration variables at $localDfSettings'
        let json = json_decode(readfile(localDfSettings))

        " Supported settings
        for key in keys(json)
            let value = get(json, key, '')

            "echom '  - Let ' . key . ' equal ' . value
            let letText = "let " . key . " = '" . value . "'"

            exec(letText)
        endfor
    endif
endfunction

call s:IncludeDotfilesVim()
call s:IncludeDotfilesJson()
" }}}


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

    " Syntax and Language Support {{{
    Plug 'PProvost/vim-ps1' " PowerShell
    Plug 'w0rp/ale' " Asynchronous Lint Engine
    Plug 'docker/docker', {'for': 'dockerfile'} " For Dockerfiles
    Plug 'JamshedVesuna/vim-markdown-preview' " Markdown previewing
    Plug 'pangloss/vim-javascript', {'for': 'javascript'} " For Javascript
    " }}}

    Plug 'justinmk/vim-dirvish'
    Plug 'kristijanhusak/vim-dirvish-git'

    " PlantUML {{{
    Plug 'aklt/plantuml-syntax' " PlantUml Syntax. Configures :make with default plantuml in PATH.
    Plug 'tyru/open-browser.vim' " Depndency for weirongxu/plantuml-previewer.vim
    Plug 'weirongxu/plantuml-previewer.vim' " PlantUML Previewer. Adds  :PlantumlOpen command.
    " }}}

    " Terraform {{{
    Plug 'hashivim/vim-terraform', {'for': ['tf', 'terraform', 'tfvars']}
    " }}}

call plug#end()
" }}}

" Syntax and Language Support{{{

    " 'PProvost/vim-ps1' {{{
    " Unfold script blocks. Used when `foldmethod` is `syntax`
        let g:ps1_nofold_blocks=1
    " }}}

    " 'hashivim/vim-terraform' {{{
        let g:terraform_align=1 " Override indentation syntax for matching files.
		let g:terraform_fmt_on_save=1 " Allow vim-terraform to automatically format *.tf and *.tfvars
            " files with terraform fmt. You can also do this manually with the :TerraformFmt command.
    " }}}

    " 'kristijanhusak/vim-dirvish-git' {{{
        let g:dirvish_git_show_ignored = 1 " Show ignored Git files by default in Dirvish.
    " }}}

    " 'JamshedVesuna/vim-markdown-preview' {{{
        let g:vim_markdown_preview_hotkey='<Leader>p' " Opens preview
    " }}}

    " 'pangloss/vim-javascript' {{{
        let g:javascript_plugin_jsdoc = 1 " Allow highlighting of JSDoc Files
        let g:javascript_plugin_flow = 1  " Enable Flow syntax
    " }}}

    " 'w0rp/ale' {{{
        let g:ale_linters = {
        \   'javascript': ['flow'],
        \   'markdown': ['markdownlint'],
        \   'terraform': ['fmt', 'tflint'],
        \}

        let g:ale_fixers = {
        \   '*': ['remove_trailing_lines', 'trim_whitespace'],
        \   'javascript': ['eslint'],
        \}

        " Set this variable to 1 to fix files when you save them.
        let g:ale_fix_on_save = 1
    " }}}
" }}}


" mileszs/ack.vim {{{

" Avoid errors on Windows by turning off gitgutter grep by default
let g:gitgutter_grep=''

if executable('grep')
    " Use Grep for :Ack commands, since it exists
    let g:gitgutter_grep='grep'
    set grepprg=grep
endif

if executable('rg')
    " Use RipGrep (rg) for :Ack commands
    let g:ackprg='rg --vimgrep --no-heading'
    let g:gitgutter_grep='rg'
    set grepprg=rg\ --vimgrep\ --no-heading

    " Use the ripgrep_config_override in local.dotfiles.json.
    " Why not just use the shell? This is more consitent for
    " vim than relying only on the shell.
    if exists("g:ripgrep_config") && !empty(g:ripgrep_config)
        let $RIPGREP_CONFIG_PATH = g:ripgrep_config
    endif

    set grepformat=%f:%l:%c:%m,%f:%l:%m
                  " |  |  |  + Message
                  " |  |  + Column Number
                  " |  + Line Number
                  " + Filename
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

    if has('macunix')
        LuciusDarkHighContrast
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

if executable('rg')
    " fzf (Fuzzy Finder)
    "   - Use rg (RipGrep) if available
    "   - Filename list
    "   - Greedy file listing with hidden and .gitignore included
    " NOTE: Should be same as ../WindowsPowerShell/profile.ps1
    "   !!EXCEPT FOR!! the --vimdiff should not be used in PowerShell
    "   Consider RIPGREP_CONFIG_PATH if this becomes a PITA
    let $FZF_DEFAULT_COMMAND='rg --files '

    " Rg (RipGrep) for Fzf
    command! -bang -nargs=* FzfRg
      \ call fzf#vim#grep(
      \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
      \   <bang>0 ? fzf#vim#grep('up:60%')
      \           : fzf#vim#grep('right:50%:hidden', '?'),
      \   <bang>0)

    " Mappings
    nnoremap <Leader>f?     :help fzf-vim<CR>

    " Files, cwd
    nnoremap <Leader>ff     :FzfFiles<CR>

    " Files, buffer's directory
    nnoremap <Leader>fF     :FzfFiles <C-R>=expand('%:p:h')<CR><CR>

    " Buffers
    nnoremap <Leader>fb     :FzfBuffers<CR>

    " Windows and Tabs
    nnoremap <Leader>fw     :FzfWindows<CR>
endif

" }}}

" Plugin: vim-fugitive {{{

    " Mappings
    nnoremap <Leader>g?     :help fugitive<CR>

    " commit (:Gcommit based)
    nnoremap <Leader>gcA    :Gcommit --amend --reuse-message=HEAD
    nnoremap <Leader>gca    :Gcommit --amend
    nnoremap <Leader>gcva   :Gcommit --amend --verbose
    nnoremap <Leader>gcc    :Gcommit
    nnoremap <Leader>gcvc   :Gcommit --verbose

    " diff (:Gdiff based)
    nnoremap <Leader>gD     :Gdiff<CR>
    nnoremap <Leader>gds    :Gsdiff<CR>
    nnoremap <Leader>gdv    :Gvdiff<CR>

    " patch (add/reset)
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
nnoremap <Leader>cd :cd %:p:h<CR>:pwd<CR> " Set vim's working directory to the current file.

" Location List - Local file linting, errors, etc.
nnoremap <Leader>lo :lopen<CR>     " Opens the local list.
nnoremap <Leader>lc :lclose<CR>    " Closes the local list.
nnoremap <Leader>ln :lnext<CR>     " Open the next item in the local list.
nnoremap <Leader>lp :lprevious<CR> " Open the previous item in the local list.

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

function! ToggleTargetingComputer()
    if &cursorcolumn
        setlocal nocursorcolumn
        setlocal nocursorline
    else
        setlocal cursorcolumn
        setlocal cursorline
    endif
endfunction

augroup filetype_markdown
    autocmd!
    " Turn spell check on for the buffer
    autocmd BufNewFile,BufRead *.md setlocal spell
    autocmd BufNewFile,BufRead *.rdoc setlocal spell
augroup END
