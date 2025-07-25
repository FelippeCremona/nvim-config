M = {}

local opts = { noremap = true, silent = true }
-- For the description on keymaps, I have a function getOptions(desc) which returns noremap=true, silent=true and desc=desc. Then call: keymap(mode, keymap, command, getOptions("some randome desc")

local keymap = vim.keymap.set

-- Insert --

-- Normal --
keymap("n", "tt", "zt", opts)


-- Better window navigation
keymap("n", "<m-h>", "<C-w>h", opts)
keymap("n", "<m-j>", "<C-w>j", opts)
keymap("n", "<m-k>", "<C-w>k", opts)
keymap("n", "<m-l>", "<C-w>l", opts)
keymap("n", "<m-tab>", "<c-6>", opts)

-- Melhora o Ctrl d e Ctrl u
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<Left>", "<gv", opts)
keymap("v", "<Right>", ">gv", opts)

keymap("v", "p", '"_dP', opts)

-- Nvimtree
keymap("n", "<space>e", "<cmd>NvimTreeToggle<cr>", opts)

-- Harpoon
keymap("n", "<A-y>", "<cmd>lua require('harpoon.mark').add_file()<cr>", opts)
keymap("n", "<A-t>", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", opts)

keymap("n", "<A-u>", "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", opts)
keymap("n", "<A-i>", "<cmd>lua require('harpoon.ui').nav_file(2)<cr>", opts)
keymap("n", "<A-o>", "<cmd>lua require('harpoon.ui').nav_file(3)<cr>", opts)
keymap("n", "<A-p>", "<cmd>lua require('harpoon.ui').nav_file(4)<cr>", opts)

-- Navigate buffers
keymap("n", "<S-Tab>", ":bprevious<CR>", opts)
keymap("n", "<C-w>", ":bd<CR>", opts)

-- Atalho Telescope
keymap("n", ",F", "<cmd>Telescope find_files<cr>", opts)
keymap("n", ",f", "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy({layout_config={height=10}, previewer=false, defaults={path_display={'absolute'}}}))<cr>", opts)
keymap("n", ",g", "<cmd>Telescope live_grep<cr>", opts)
keymap("n", ",G", "<cmd>lua require('telescope.builtin').live_grep(require('telescope.themes').get_ivy({layout_config={height=10}, previewer=false, defaults={path_display={'absolute'}}}))<cr>", opts)

keymap("n", ",d", "<cmd>lua require('telescope.builtin').diagnostics()<cr>", opts)

-- Atalho LSP
keymap('n', ',e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
keymap('n', 'gr', '<cmd> lua vim.lsp.buf.references()<CR>')
keymap('n','gD','<cmd>lua vim.lsp.buf.declaration()<CR>')
keymap('n','gd','<cmd>lua vim.lsp.buf.definition()<CR>')
keymap('n','K','<cmd>lua vim.lsp.buf.hover()<CR>')
keymap('n','gs','<cmd>lua vim.lsp.buf.signature_help()<CR>')
keymap('n','gi','<cmd>lua vim.lsp.buf.implementation()<CR>')
keymap('n','gt','<cmd>lua vim.lsp.buf.type_definition()<CR>')
keymap('n','<space>gw','<cmd>lua vim.lsp.buf.document_symbol()<CR>')
keymap('n','<space>gW','<cmd>lua vim.lsp.buf.workspace_symbol()<CR>')
keymap('n',',af','<cmd>lua vim.lsp.buf.code_action()<CR>')
keymap('n','<C-A-r>','<cmd>lua vim.lsp.buf.rename()<CR>')
keymap('n','<space>ai','<cmd>lua vim.lsp.buf.incoming_calls()<CR>')
keymap('n','<space>ao','<cmd>lua vim.lsp.buf.outgoing_calls()<CR>')

keymap("n", "<C-A-o>", "<Cmd>lua require'jdtls'.organize_imports()<CR>", opts)
-- keymap("n", "<C-A-n>", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR> <cmd>CodeActionMenu<CR> ", opts)
keymap("n", "<C-A-n>", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR> <cmd>lua vim.lsp.buf.code_action()<CR> ", opts)

-- Atalhos JDTLS
-- keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)

-- Atalhos DAP
keymap('n', '<space>dt', ':lua require("dap").toggle_breakpoint()<CR>')
keymap('n', '<F1>', ':lua require("dap.ui.widgets").centered_float(require("dap.ui.widgets").frames)<CR>')
keymap('n', '<F2>', ':lua require("dap.ui.widgets").hover()<CR>')
keymap('n', '<F3>', ':lua require"dap".repl.toggle({height=8})<CR>')
keymap('n', '<F4>', ':lua require"dap.ui.widgets".centered_float(require"dap.ui.widgets".scopes)<CR>')
keymap('n', '<F8>', ':lua require"dap".continue()<CR>')
keymap('n', '<F10>', ':lua require"dap".step_over()<CR>')
keymap('n', '<F11>', ':lua require"dap".step_into()<CR>')
keymap('n', '<S-11>', ':lua require"dap".step_out()<CR>')
keymap('n', '<F12>', ':lua require("dapui").toggle()<CR>')

-- Undotree
keymap('n', '<S-u>', '<cmd>UndotreeToggle<CR>')

-- Diagnostic keymaps
keymap('n', '[d', vim.diagnostic.goto_prev)
keymap('n', ']d', vim.diagnostic.goto_next)

-- Incrementa e Decrementa numero
keymap("n", "<A-Up>", "<C-a>", opts)
keymap("n", "<A-Down>", "<C-x>", opts)

keymap('n', '<C-A-t>', '<cmd>lua require("utils").run_java_test_method()<CR>', opts)
keymap('n', '<C-A-p>', '<cmd>lua require("utils").run_java_test_class()<CR>', opts)

return M
