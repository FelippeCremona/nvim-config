return {
  "williamboman/mason.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig"
  },
  config = function()
    -- import mason plugin safely
    local mason = require("mason")

    -- import mason-lspconfig plugin safely
    local mason_lspconfig = require("mason-lspconfig")

    -- enable mason
    mason.setup()

    mason_lspconfig.setup({
      -- list of servers for mason to install
      ensure_installed = {
        "ts_ls",
        "html",
        "jdtls",
        "cssls",
        "svelte",
        "lua_ls",
        "graphql",
        "emmet_ls",
        "prismals",
        "pyright",
      },

      -- auto-install configured servers (with lspconfig)
      automatic_installation = true, -- not the same as ensure_installed
    })

  end,
}
