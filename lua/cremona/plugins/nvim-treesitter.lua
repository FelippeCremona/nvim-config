return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
      "windwp/nvim-ts-autotag",
    },
    config = function()
      -- import nvim-treesitter plugin
      local treesitter = require("nvim-treesitter.configs")

      -- configure treesitter
      treesitter.setup({ -- enable syntax highlighting
        highlight = {
          enable = true,
        },
        -- enable indentation
        indent = { enable = false },
        -- enable autotagging (w/ nvim-ts-autotag plugin)
        autotag = { enable = true },
        -- ensure these language parsers are installed
        ensure_installed = {
          "xml",
          "json",
          "javascript",
          "typescript",
          "java",
          "tsx",
          "yaml",
          -- "html",
          "css",
          "prisma",
          "markdown",
          "markdown_inline",
          -- "svelte",
          "graphql",
          "bash",
          "lua",
          "vim",
          "dockerfile",
          "gitignore",
        },
        -- enable nvim-ts-context-commentstring plugin for commenting tsx and jsx
        -- auto_install = true,
      })
    end,

    -- require('ts_context_commentstring').setup {
    --   enable_autocmd = false,
    -- }
  },
}
