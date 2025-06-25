return {
  {
    "bluz71/vim-nightfly-guicolors",
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- load the colorscheme here
      vim.cmd([[colorscheme nightfly]])
    end,
  },

}

--
-- return {
--   {
--     "morhetz/gruvbox",
--     config = function()
--       -- load the colorscheme here
--       vim.cmd([[colorscheme gruvbox]])
--     end,
--   }
-- }


-- return {
--   {
--     "vague2k/vague.nvim",
--     config = function()
--       -- load the colorscheme here
--       vim.cmd([[colorscheme vague]])
--     end,
--   }
-- }


