return {
  "nvim-tree/nvim-tree.lua",
  cmd = "NvimTreeToggle",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local nvimtree = require("nvim-tree")

    -- change color for arrows in tree to light blue
    vim.cmd([[ highlight NvimTreeIndentMarker guifg=#3FC5FF ]])

    -- configure nvim-tree
    nvimtree.setup({
      sort_by = "case_sensitive",
      view = {
        adaptive_size = true,
        side = "right",
      },
      renderer = {
        group_empty = true,
      },
      update_focused_file = {
        enable = true,
        update_cwd = false,
        ignore_list = {},
      },
      filters = {
        dotfiles = false,
      },
    })

  end,
}
