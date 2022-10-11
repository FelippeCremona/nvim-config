-- Globais
require "global.options"
require "global.keymaps"
require "global.plugins"
require "global.colorscheme"

-- Plugins
--[[ require "config-plugins.cmp" -- rever o video: https://www.youtube.com/watch?v=GuIcGxYqaQQ&list=PLhoH5vyxr6Qq41NFL4GvhFp-WLd5xzIzZ&index=6 ]]
--[[ require "config-plugins.lsp" ]]
require "config-plugins.telescope"
require "config-plugins.lualine"
require "config-plugins.treesitter"
require "config-plugins.autopairs"
require "config-plugins.gitsigns"
require "config-plugins.notify"
require "config-plugins.bufferline"
--[[ require "config-plugins.whichkey" ]]
require "config-plugins.comment"
require "config-plugins.nvim-tree"
require "config-plugins.colorizer"
require "config-plugins.nvim-jdtls"
require "config-plugins.compe"
require "config-plugins.marks"
--[[ require("config-plugins.harpoon") ]]

-- Globais em Vimscript
vim.cmd "source $HOME/AppData/Local/nvim/vimscripts/global/keymaps.vim"
vim.cmd "source $HOME/AppData/Local/nvim/vimscripts/global/functions.vim"

-- Plugins em Vimscript
vim.cmd "source $HOME/AppData/Local/nvim/vimscripts/config-plugins/surround.vim"
vim.cmd "source $HOME/AppData/Local/nvim/vimscripts/config-plugins/coc.vim"
--[[ vim.cmd "source $HOME/AppData/Local/nvim/vimscripts/config-plugins/vimspector.vim" ]]
vim.cmd "source $HOME/AppData/Local/nvim/vimscripts/config-plugins/vim-bujo.vim"
