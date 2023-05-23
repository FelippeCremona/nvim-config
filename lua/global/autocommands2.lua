local au = vim.api.nvim_create_autocmd
local ag = vim.api.nvim_create_augroup

-- GROUPS:
local disable_node_modules_eslint_group =
	ag("DisableNodeModulesEslint", { clear = true })

-- AUTO-COMMANDS:
au({ "BufNewFile", "BufRead" }, {
	pattern = { "**/node_modules/**", "node_modules", "/node_modules/*" },
	callback = function()
		vim.diagnostic.disable(0)
	end,
	group = disable_node_modules_eslint_group,
})

au({"BufEnter", "BufRead"}, {
  callback = function ()
    vim.diagnostic.disable()
  end
})
