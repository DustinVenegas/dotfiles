" nvim-qt configuration file

" Load a font, but use bang (!) to ignore errors with fixed pitch errors.
" TODO: Resolve or consider using a try/catch with error handling so we don't lose
" the error.
"Guifont! DejaVu Sans Mono:h12
GuiFont! Hack:h12

" Maxamize the window. Due to `GuiFont!` causing errors, nvim-qt starts too
" small. This forcefully maximizes the window as a workaround
call rpcnotify(0, 'Gui', 'WindowMaximized', 1)
