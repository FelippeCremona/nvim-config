local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

-- Install your plugins here
return packer.startup(function(use)
  -- My plugins here
  use "wbthomason/packer.nvim" -- Have packer manage itself
  use "nvim-lua/popup.nvim" -- An implementation of the Popup API from vim in Neovim
  use "nvim-lua/plenary.nvim" -- Useful lua functions used ny lots of plugins

  use "antoinemadec/FixCursorHold.nvim" -- This is needed to fix lsp doc highlight

  -- Load on a combination of conditions: specific filetypes or commands
  -- Also run code after load (see the "config" key)
  --[[ use 'w0rp/ale' ]]
  --[[ use 'dense-analysis/ale' ]]
  -- Post-install/update hook with neovim command

  -- Treesitter
  use {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate", }

  -- nvim-tree
  use 'kyazdani42/nvim-web-devicons'
  use 'kyazdani42/nvim-tree.lua'

  -- Colorschemes
  --[[ use {'dracula/vim'} ]]
  --[[ use {'folke/tokyonight.nvim'} ]]
  use 'tanvirtin/monokai.nvim'

  -- Telescope
  use "nvim-telescope/telescope.nvim"
  use 'nvim-telescope/telescope-media-files.nvim'

  -- snippets
  use "L3MON4D3/LuaSnip" --snippet engine
  use "rafamadriz/friendly-snippets" -- a bunch of snippets to use

  -- COC
  --[[ use {'neoclide/coc.nvim', branch = 'release' } ]]

  -- Lualine
  use {'nvim-lualine/lualine.nvim', requires = { 'kyazdani42/nvim-web-devicons', opt = true }}

  -- Colorizer
  use 'norcalli/nvim-colorizer.lua'

  -- Notify
  use 'rcarriga/nvim-notify'

  -- Git
  use "lewis6991/gitsigns.nvim"

  -- Commentario
  use "numToStr/Comment.nvim" -- Easily comment stuff
  use 'JoosepAlviste/nvim-ts-context-commentstring'

  use "windwp/nvim-autopairs" -- Autopairs, integrates with both cmp and treesitter
  --[[ use "folke/which-key.nvim" ]]

  use {'akinsho/bufferline.nvim', tag = "v2.*", requires = 'kyazdani42/nvim-web-devicons'}

  -- surround
  use 'tpope/vim-surround'

  -- debbug java
  --[[ use 'puremourning/vimspector' ]]

  -- todo list
  use 'vuciv/vim-bujo'

  -- show marks
  use 'chentoast/marks.nvim'

  -- harpoon
  --[[ use { 'ThePrimeagen/harpoon', requires = "nvim-lua/plenary.nvim" } ]]

   -- cmp plugins
  --[[ use "hrsh7th/nvim-cmp" -- The completion plugin ]]
  --[[ use "hrsh7th/cmp-buffer" -- buffer completions ]]
  --[[ use "hrsh7th/cmp-path" -- path completions ]]
  --[[ use "hrsh7th/cmp-cmdline" -- cmdline completions ]]
  --[[ use "hrsh7th/cmp-nvim-lsp" ]]
  --[[ use "saadparwaiz1/cmp_luasnip" -- snippet completions ]]

  -- LSP
  use "neovim/nvim-lspconfig" -- enable LSP
  use "hrsh7th/nvim-compe"
  use "williamboman/nvim-lsp-installer" -- simple to use language server installer
  --[[ use 'arkav/lualine-lsp-progress' ]]

  -- jdtls (java)
  use 'mfussenegger/nvim-jdtls'

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
