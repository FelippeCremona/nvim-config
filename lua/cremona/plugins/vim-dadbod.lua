return {
  { "tpope/vim-dadbod", lazy = true },

  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = { "tpope/vim-dadbod" },
    ft = { "sql", "mysql", "plsql" },
  },

  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    init = function()
      -- Precisa estar setado antes do plugin carregar. A conexão em si (g:db)
      -- vem do init.lua — o dadbod-ui já lista g:db sozinho, sem precisar
      -- duplicar em g:dbs.
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui_queries"
    end,
    config = function()
      -- Autocomplete de tabela/coluna specific do buffer conectado, integrado
      -- ao nvim-cmp já usado no resto da config.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          require("cmp").setup.buffer({
            sources = {
              { name = "vim-dadbod-completion" },
              { name = "buffer" },
            },
          })
        end,
      })
    end,
  },
}
