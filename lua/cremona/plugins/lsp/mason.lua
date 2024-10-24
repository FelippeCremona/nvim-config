return {
  "williamboman/mason.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "jayp0521/mason-null-ls.nvim",
    "neovim/nvim-lspconfig"
    -- {'j-hui/fidget.nvim', tag = 'legacy'},
  },
  config = function()
    -- import mason plugin safely
    local mason = require("mason")

    -- import mason-lspconfig plugin safely
    local mason_lspconfig = require("mason-lspconfig")

    -- import mason-null-ls plugin safely
    local mason_null_ls = require("mason-null-ls")

    -- enable mason
    mason.setup()

    mason_lspconfig.setup({
      -- list of servers for mason to install
      ensure_installed = {
        -- "tsserver",
        "ts_ls",
        "html",
        -- "jdtls",
        "cssls",
        -- "tailwindcss",
        "svelte",
        "lua_ls",
        "graphql",
        "emmet_ls",
        "prismals",
      },
      -- auto-install configured servers (with lspconfig)
      automatic_installation = true, -- not the same as ensure_installed
    })

    mason_null_ls.setup({
      -- list of formatters & linters for mason to install
      ensure_installed = {
        'java-debug-adapter',
        'java-test',
      --   "prettier", -- ts/js formatter
      --   "stylua", -- lua formatter
      --   "eslint_d", -- ts/js linter
      },
      -- auto-install configured servers (with lspconfig)
      automatic_installation = true,
    })
  end,
}
