return {
    "akinsho/git-conflict.nvim",
    version = "*",
    config = function()
        require("git-conflict").setup({
            default_mappings = true,
            default_commands = true,
            disable_diagnostics = false,
            list_opener = "copen",
        })
    end,
}
