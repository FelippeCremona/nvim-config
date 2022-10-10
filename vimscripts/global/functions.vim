" Evidencia a palavra que esta selecionada
function! HighlightWordUnderCursor()
    if getline(".")[col(".")-1] !~# '[[:punct:][:blank:]]'
        exec 'match' 'Search' '/\V\<'.expand('<cword>').'\>/'
    else
        match none
    endif
endfunction

autocmd! CursorHold,CursorHoldI * call HighlightWordUnderCursor()


" augroup lsp
"   au!
"   au FileType java lua require'config-plugin.lsp.lsp-handlers'.setup()
" augroup end
