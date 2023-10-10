return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")

    vim.g.gitblame_display_virtual_text = 0 -- Disable virtual text
    vim.g.gitblame_message_template = '<author> • <date>'
    -- vim.g.gitblame_date_format = '%r'
    vim.g.gitblame_date_format = '%d/%m/%Y %H:%M:%S'
    local git_blame = require('gitblame')
    -- configure lualine with modified theme
    lualine.setup({
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        lualine_c = {
          { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available },
        },
        lualine_x = {
          {"filename"}
        }
      }
    })
  end,
}
