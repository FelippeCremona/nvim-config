call plug#begin()

"Temas
"Plug 'joshdick/onedark.vim'
Plug 'sainnhe/sonokai'

" Airlin
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'ryanoasis/vim-devicons'
" Plug 'sheerun/vim-polyglot'

" NERDTree
Plug 'preservim/nerdtree'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

"Git plugin
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'junegunn/gv.vim'

" Plug 'dense-analysis/ale'
"
" COC
Plug 'neoclide/coc.nvim' , { 'branch' : 'release' }

" SNIPPETS
Plug 'honza/vim-snippets'
Plug 'jiangmiao/auto-pairs'

" Comment
Plug 'preservim/nerdcommenter'

if (has("nvim"))
    " Telescope
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'

    " Treesitter
	Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

    " LSP
    Plug 'neovim/nvim-lspconfig'
endif
call plug#end()



" Global Sets """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype plugin indent on
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab smarttab autoindent
set incsearch ignorecase smartcase hlsearch
set wildmode=longest,list,full wildmenu
set ruler laststatus=2 showcmd showmode
set list listchars=trail:»,tab:»-
set fillchars+=vert:\ 
" set wrap breakindent linebreak
set nowrap
set encoding=utf-8
set textwidth=0
set hidden
set number relativenumber
" set title
set cursorline
set mouse=a
" set nolazyredraw

if !has("gui_running")
    "set term=xterm
    "set t_Co=256
    let &t_AB="\e[48;5;%dm"
    let &t_AF="\e[38;5;%dm"
    "colorscheme zenburn
endif

" Themes """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"source $HOME/AppData/Local/nvim/themes/onedark.vim
source $HOME/AppData/Local/nvim/themes/sonokai.vim

" Remaps """"""""""
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

nnoremap <M-j> :resize -2 <CR>
nnoremap <M-k> :resize +2 <CR>
nnoremap <M-h> :vertical resize -2 <CR>
nnoremap <M-l> :vertical resize +2 <CR>


nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

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

"NAO-FUNCIONA / Autocomplete no ctrl espaço
"inoremap <silent><expr> <C-Space> compe#complete()
"inoremap <silent><expr> <C-e>     compe#close('<C-e>')
" remaps aqui



" autocmd """"""""""
function! HighlightWordUnderCursor()
    if getline(".")[col(".")-1] !~# '[[:punct:][:blank:]]'
        exec 'match' 'Search' '/\V\<'.expand('<cword>').'\>/'
    else
        match none
    endif
endfunction

autocmd! CursorHold,CursorHoldI * call HighlightWordUnderCursor()
" autocmds aqui


" COC """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
source $HOME/AppData/Local/nvim/coc/coc.vim


" TELESCOPE """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
source $HOME/AppData/Local/nvim/telescope/telescope.vim


" AirLine """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1


" NerdTree """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
source $HOME/AppData/Local/nvim/nerdtree/nerdtreee.vim


" ALE """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:ale_fixers = {
" \   '*': ['trim_whitespace'],
" \}

" let g:ale_fix_on_save = 1


source $HOME/AppData/Local/nvim/lua/treesitter.lua


