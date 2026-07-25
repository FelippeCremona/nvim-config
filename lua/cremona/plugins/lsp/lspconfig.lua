return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    {
      "smjonas/inc-rename.nvim",
      config = true,
    },
  },
  config = function()
    -- import lspconfig plugin

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    -- used to enable autocompletion (assign to every lsp server config)

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- configure html server
    -- lspconfig["html"].setup({
    --   capabilities = capabilities,
    --   on_attach = on_attach,
    -- })

    vim.lsp.enable("html")
    vim.lsp.enable("cssls")
    vim.lsp.enable("svelte")
    vim.lsp.enable("prismals")
    vim.lsp.enable("graphql")
    vim.lsp.enable("emmet_ls")


    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
          },

          diagnostics = {
            globals = { "vim" },
          },

          workspace = {
            checkThirdParty = false,

            library = {
              vim.env.VIMRUNTIME,
              vim.fn.stdpath("config"),
            },
          },

          telemetry = {
            enable = false,
          },
        },
      },
    })

    vim.lsp.enable("lua_ls")



    -- O typescript-language-server tem shebang "#!/usr/bin/env node", então
    -- normalmente roda com o node ativo no momento via `n` — quebra quando
    -- o projeto exige `n use 14` (Node 14 é velho demais pro ts_ls atual).
    -- Aqui ele roda explicitamente com uma versão fixa e mais nova do node
    -- (instalada via `n`), independente da versão ativa pro projeto.
    vim.lsp.config("ts_ls", {
      cmd = {
        "/usr/local/n/versions/node/20.20.2/bin/node",
        "/usr/local/bin/typescript-language-server",
        "--stdio",
      },

      filetypes = {
        "typescript",
        "typescriptreact",
        "javascript",
        "javascriptreact",
      },

      root_markers = {
        "package.json",
        "tsconfig.json",
        "jsconfig.json",
        ".git",
      },

      init_options = {
        tsserver = {
          globalTsdk = "/usr/local/lib/node_modules/typescript/lib",
        },
      },

      settings = {
        typescript = {
          inlayHints = {
            includeInlayParameterNameHints = "all",
          },
        },
      },
    })

    vim.lsp.enable("ts_ls")

  end,
}
