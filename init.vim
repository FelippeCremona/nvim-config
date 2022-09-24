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
Plug 'mhinz/vim-signify'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'junegunn/gv.vim'

"
" COC - só funcionou bem junto com o plugin do ALE
Plug 'neoclide/coc.nvim' , { 'branch' : 'release' }
Plug 'dense-analysis/ale' " Funciona junto com o plugin do COC

" SNIPPETS
Plug 'honza/vim-snippets'
Plug 'jiangmiao/auto-pairs'

" Comment
Plug 'preservim/nerdcommenter'

" Todo List
Plug 'vuciv/vim-bujo'

" Debug
Plug 'puremourning/vimspector'

if (has("nvim"))
    " Telescope
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'

    " Treesitter
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

    " LSP
    "Plug 'neovim/nvim-lspconfig'
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
set t_Co=256                            " Support 256 colors
set background=dark                     " tell vim what the background color looks like
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

" Todo list
nmap <Leader>td :Todo g<CR>
nmap <Leader>tl :Todo<CR>

nmap <C-P> <Plug>BujoAddnormal
imap <C-P> <Plug>BujoAddinsert

nmap <C-Q> <Plug>BujoChecknormal
imap <C-Q> <Plug>BujoCheckinsert
let g:bujo#window_width = 80

" autocmd """"""""""
"
" Evidencia a palavra que esta selecionada
function! HighlightWordUnderCursor()
    if getline(".")[col(".")-1] !~# '[[:punct:][:blank:]]'
        exec 'match' 'Search' '/\V\<'.expand('<cword>').'\>/'
    else
        match none
    endif
endfunction

autocmd! CursorHold,CursorHoldI * call HighlightWordUnderCursor()
" autocmds aqui

" Configurações dos Plugins
source $HOME/AppData/Local/nvim/plugins/coc/coc.vim
source $HOME/AppData/Local/nvim/plugins/telescope/telescope.vim
source $HOME/AppData/Local/nvim/plugins/airline/airline.vim
source $HOME/AppData/Local/nvim/plugins/nerdtree/nerdtreee.vim
source $HOME/AppData/Local/nvim/plugins/ale/ale.vim
source $HOME/AppData/Local/nvim/plugins/treesitter/treesitter.lua
source $HOME/AppData/Local/nvim/plugins/vimspector/vimspector.vim
source $HOME/AppData/Local/nvim/plugins/signify/signify.vim
