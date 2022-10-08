local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

require "config-plugins.lsp.lsp-installer"
--require("config-plugins.lsp.handlers").setup()
