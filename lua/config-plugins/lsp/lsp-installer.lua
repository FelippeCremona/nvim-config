local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not status_ok then
	return
end

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp_installer.on_server_ready(function(server)
	local opts = {
		--[[ on_attach = require("config-plugins.lsp.handlers").on_attach, ]]
		--[[ capabilities = require("config-plugins.lsp.handlers").capabilities, ]]
	}


  if server.name == "jsonls" then
    local jsonls_opts = require("config-plugins.lsp.settings.jsonls")
    opts = vim.tbl_deep_extend("force", jsonls_opts, opts)
  end

  if server.name == "sumneko_lua" then
    local sumneko_opts = require("config-plugins.lsp.settings.sumneko_lua")
    opts = vim.tbl_deep_extend("force", sumneko_opts, opts)
  end

  if server.name == "tsserver" then
    local tsserver_opts = require("config-plugins.lsp.settings.tsserver")
    opts = vim.tbl_deep_extend("force", tsserver_opts, opts)
  end

  --[[ if server.name == "jdtls" then ]]
  --[[   local jdtls_opts = require("config-plugins.lsp.settings.jdtls") ]]
  --[[   opts = vim.tbl_deep_extend("force", jdtls_opts, opts) ]]
  --[[ end ]]

	-- This setup() function is exactly the same as lspconfig's setup function.
	-- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
	server:setup(opts)
end)
