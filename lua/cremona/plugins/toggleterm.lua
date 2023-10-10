return{
  'akinsho/toggleterm.nvim', version = "*",
  config = function ()
    require("toggleterm").setup{
      direction = "horizontal",
      size = 15,
      open_mapping = [[<C-t>]]
    }
  end
}
