return {
  {
    "nvim-treesitter/nvim-treesitter",
    tag = "v0.10.0",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",

    dependencies = {
      "windwp/nvim-ts-autotag",
      "nvim-treesitter/nvim-treesitter-textobjects",
    },

    config = function()
      local treesitter = require("nvim-treesitter.configs")

      treesitter.setup({
        highlight = {
          enable = true,
        },

        indent = {
          enable = false,
        },

        autotag = {
          enable = true,
        },

        ensure_installed = {
          "xml",
          "json",
          "javascript",
          "typescript",
          "java",
          "tsx",
          "yaml",
          "css",
          "prisma",
          "markdown",
          "markdown_inline",
          "graphql",
          "bash",
          "lua",
          "vim",
          "dockerfile",
          "gitignore",
        },
      })
    end,
  },
}
