local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true, expr = false }

keymap("n", ",m", [[ <Cmd> lua require('harpoon.mark').add_file()<CR> ]], opts)
keymap("n", ",h", [[ <Cmd> lua require('harpoon.ui').toggle_quick_menu()<CR> ]], opts)

keymap("n", ",1", [[ :lua require("harpoon.ui").nav_file(1)<CR> ]], opts)
keymap("n", ",2", [[ :lua require("harpoon.ui").nav_file(2)<CR> ]], opts)
keymap("n", ",3", [[ :lua require("harpoon.ui").nav_file(3)<CR> ]], opts)
keymap("n", ",4", [[ :lua require("harpoon.ui").nav_file(4)<CR> ]], opts)
