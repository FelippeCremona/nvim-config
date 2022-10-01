"compiler java
let g:vimspector_enable_mappings = 'HUMAN'
"nmap <leader>dd :call vimspector#Launch()<CR>
nmap ,, :VimspectorReset<CR>
nmap ,eval :VimspectorEval 
nmap <leader>dw :VimspectorWatch
nmap <leader>do :VimspectorShowOutput
nmap ,bp <Plug>VimspectorToggleBreakpoint
nmap <C-n> <Plug>VimspectorStepOver
nmap <C-l> <Plug>VimspectorRunToCursor
nmap <C-m> <Plug>VimspectorContinue
"nmap <C-p> <Plug>VimspectorStop
autocmd FileType java nmap ,dd :CocCommand java.debug.vimspector.start<CR>


let g:vimspector_sidebar_width = 30
let g:vimspector_bottombar_height = 2
"let g:vimspector_code_minwidth = 90
"let g:vimspector_terminal_maxwidth = 75
"let g:vimspector_terminal_minwidth = 20
"
function! s:VimspectorCustomiseUI()
  " Make the variables window 50 lines high
  call win_gotoid( g:vimspector_session_windows.variables )
  50wincmd _
endfunction

augroup MyVimspectorUICustom
  autocmd!
  autocmd User VimspectorUICreated call s:VimspectorCustomiseUI()
augroup END
