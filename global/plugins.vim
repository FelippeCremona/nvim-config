call plug#begin()
"Temas
"Plug '/joshdick/onedark.vim'
Plug 'sainnhe/sonokai'

" Airlin
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'



"Plug 'kyazdani42/nvim-web-devicon'
Plug 'akinsho/bufferline.nvim'

Plug 'ryanoasis/vim-devicons'
" Plug 'sheerun/vim-polyglot'

" NERDTree
"Plug 'preservim/nerdtree'
"Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

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

" Colorizer
Plug 'norcalli/nvim-colorizer.lua'

" which-key
" Plug 'liuchengxu/vim-which-key'

" Banco de Dados - não consegui fazer funcionar com o Oracle
"Plug 'tpope/vim-dadbod'
"Plug 'kristijanhusak/vim-dadbod-ui'

" vim-surround
Plug 'tpope/vim-surround'

if (has("nvim"))
    " Telescope
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'

    " Treesitter
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

    " LSP
    "Plug 'neovim/nvim-lspconfig'
endif
"Plug 'neovide/neovide'
Plug 'rcarriga/nvim-notify'
Plug 'p00f/nvim-ts-rainbow'
call plug#end()
