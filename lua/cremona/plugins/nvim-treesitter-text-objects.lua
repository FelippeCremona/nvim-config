return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("nvim-treesitter-textobjects").setup({
      select = {
        lookahead = true,
        selection_modes = {
          ["@parameter.outer"] = "v",
          ["@function.outer"] = "V",
          ["@class.outer"] = "V",
        },
        include_surrounding_whitespace = true,
      },
      move = {
        set_jumps = true,
      },
    })

    local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject

    local select_keymaps = {
      ["a="] = "@assignment.outer",
      ["i="] = "@assignment.inner",

      ["a:"] = "@parameter.outer",
      ["i:"] = "@parameter.inner",

      ["ai"] = "@conditional.outer",
      ["ii"] = "@conditional.inner",

      ["al"] = "@loop.outer",
      ["il"] = "@loop.inner",

      ["ab"] = "@block.outer",
      ["ib"] = "@block.inner",

      ["af"] = "@function.outer",
      ["if"] = "@function.inner",

      ["ac"] = "@class.outer",
      ["ic"] = "@class.inner",
    }

    for key, capture in pairs(select_keymaps) do
      vim.keymap.set({ "x", "o" }, key, function()
        select_textobject(capture, "textobjects")
      end)
    end

    local swap = require("nvim-treesitter-textobjects.swap")

    vim.keymap.set("n", "<leader>on", function()
      swap.swap_next("@parameter.inner")
    end)

    vim.keymap.set("n", "<leader>op", function()
      swap.swap_previous("@parameter.inner")
    end)
  end,
}
