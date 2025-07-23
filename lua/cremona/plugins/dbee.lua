-- plugins/dbee.lua
--
return {
  "kndndrj/nvim-dbee",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  build = function()
    -- Install tries to automatically detect the install method.
    -- if it fails, try calling it with one of these parameters:
    --    "curl", "wget", "bitsadmin", "go"
    require("dbee").install()
  end,
  config = function()
    require("dbee").setup({
      -- sources = {
      --   {
      --     name = "db2",
      --     url = "db2://SNAFBD01:sna2006@172.16.160.61:5021/CSD1",
      --     type = "db2",
      --   },
      -- },
    })
  end,
}

-- return {
--   "kndndrj/nvim-dbee",
--   dependencies = {
--     "MunifTanjim/nui.nvim",
--   },
--   config = function()
--     require("dbee").setup({
--       sources = {
--         {
--           name = "db2",
--           url = "db2://SNAFBD01:sna2006@172.16.160.61:5021/CSD1",
--           type = "db2",
--         },
--       },
--     })
--   end,
--   keys = {
--     { "<leader>d", "<cmd>Dbee<cr>", desc = "Open Dbee" },
--   },
-- }
--return {
--  "kndndrj/nvim-dbee",
--  dependencies = {
--    "MunifTanjim/nui.nvim",
--  },
--  config = function()
--    require("dbee").setup({
--      sources = {
--        {
--          name = "db2",
--          type = "db2",
--          url = "db2+ibm-db://SNAFBD01:sna2006@172.16.160.61:5021/CSD1",
--        },
--      },
--    })
--  end,
--}
