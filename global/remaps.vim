" Alterna a tecla <Leader> para ,
let mapleader = "," " map leader to comma

" Alterna a tecla Esc para ,,
inoremap ,, <Esc>

" Altera entre os splits
nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>

" Resize das telas
nnoremap <M-j> :resize -2 <CR>
nnoremap <M-k> :resize +2 <CR>
nnoremap <M-h> :vertical resize -2 <CR>
nnoremap <M-l> :vertical resize +2 <CR>

" Adiciona comentarios
noremap <Leader>cc

" Alternar as tabs do buffer
nmap <Tab> :bn<CR>
nmap <S-Tab> :bp<CR>
nmap <C-w> :bd<CR>

" Ctrl C copia para o windows
vmap <C-C> "+y

" Changes all ocourrences for the text that you have typed
nnoremap <Leader>r :%s///g<Left><Left>
nnoremap <Leader>rc :%s///gc<Left><Left><Left>

xnoremap <Leader>r :s///g<Left><Left>
xnoremap <Leader>rc :s///gc<Left><Left><Left>

vnoremap * y/\V<C-R>=escape(@",'/\')<CR><CR>

" Split
nnoremap <Leader>vs :vs<CR>
nnoremap <Leader>hs :sp<CR>
