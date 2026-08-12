vim.keymap.set(
  "n",
  ",c",
  function()
    require("cremona.angularjs_goto").goto_html_controller_member()
  end,
  { buffer = 0, desc = "Ir pro controller AngularJS da view (e pro método/propriedade sob o cursor)" }
)
