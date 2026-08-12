vim.keymap.set(
  "n",
  ",a",
  function()
    require("cremona.angularjs_goto").goto_rest_endpoint()
  end,
  { buffer = 0, desc = "Ir pro endpoint Java (@Path) do método atual que chama $http" }
)
