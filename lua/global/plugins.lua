local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({

  -- Colorcheme
  "tanvirtin/monokai.nvim",
  -- "cpea2506/one_monokai.nvim",
  -- "gruvbox-community/gruvbox",
  -- "lunarvim/darkplus.nvim",
  -- "catppuccin/nvim",
  -- {"rose-pine/neovim", as = 'rose-pine'},
  -- 'folke/tokyonight.nvim',
  -- 'navarasu/onedark.nvim', -- Theme inspired by Atom
  'Mofiqul/dracula.nvim',
  -- 'olimorris/onedarkpro.nvim',
  -- 'azemoh/vscode-one-monokai',
  -- "rebelot/kanagawa.nvim",

  {
    'VonHeikemen/lsp-zero.nvim',
    lazy = true,
    dependencies = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},

      -- JAVA
      {"mfussenegger/nvim-jdtls"},
      {"mfussenegger/nvim-dap"},
      {"rcarriga/cmp-dap"},
      { "rcarriga/nvim-dap-ui",
        dependencies = {"mfussenegger/nvim-dap"},
      },
      -- Autocompletion
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'saadparwaiz1/cmp_luasnip'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-nvim-lua'},

      -- Useful status updates for LSP
      {'j-hui/fidget.nvim', tag = 'legacy'},

      -- Additional lua configuration, makes nvim stuff amazing
      -- 'folke/neodev.nvim',

      -- Snippets
      {'L3MON4D3/LuaSnip'},
      {'rafamadriz/friendly-snippets'},

      {'weilbith/nvim-code-action-menu', cmd = 'CodeActionMenu'}
    }
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    lazy = true,
    build = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    }
  },

  {
    'nvim-tree/nvim-tree.lua',
    lazy = true,
    dependencies = {
      'nvim-tree/nvim-web-devicons', -- optional, for file icons
    },
    tag = 'nightly' -- optional, updated every week. (see issue #1193)
  },

  {
    "windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup {} end
  },

  "christianchiarulli/harpoon",

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'lewis6991/gitsigns.nvim',
  'f-person/git-blame.nvim',

  'nvim-lualine/lualine.nvim', -- Fancier statusline
  'lukas-reineke/indent-blankline.nvim', -- Add indentation guides even on blank lines
  'numToStr/Comment.nvim', -- "gc" to comment visual regions/lines
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  'NvChad/nvim-colorizer.lua',
  "kylechui/nvim-surround", -- Surround
  {'kdheepak/lazygit.nvim', opt = true, cmd = {'LazyGit', 'LazyGitConfig', 'LazyGitCurrentFile', 'LazyGitFilter', 'LazyGitFilterCurrentFile'}},
  {'mbbill/undotree', opt = true, cmd = {'UndotreeToggle'}},
  {
    -- amongst your other plugins
    {'akinsho/toggleterm.nvim', version = "*", config = true}
  },
  -- Banco de Dados
  -- use 'tpope/vim-dadbod'
  -- use 'kristijanhusak/vim-dadbod-ui'

  -- Fuzzy Finder (files, lsp, etc)
  { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = vim.fn.executable 'make' == 1 },

})
