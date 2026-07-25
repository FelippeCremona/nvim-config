vim.keymap.set(
  "n",
  ",gd",
  function()
    require("cremona.angularjs_goto").goto_service_method()
  end,
  { buffer = 0, desc = "Ir pro método do serviço AngularJS sob o cursor (service.metodo)" }
)

vim.keymap.set(
  "n",
  ",gr",
  function()
    require("cremona.angularjs_goto").goto_rest_endpoint()
  end,
  { buffer = 0, desc = "Ir pro endpoint Java (@Path) do método atual que chama $http" }
)
