local opts = { noremap = true, silent = true }

--local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Better window navigation
keymap("n", "<S-h>", "<C-w>h", opts)
keymap("n", "<S-j>", "<C-w>j", opts)
keymap("n", "<S-k>", "<C-w>k", opts)
keymap("n", "<S-l>", "<C-w>l", opts)

-- Resize with arrows
keymap("n", "<A-Up>", ":resize +2<CR>", opts)
keymap("n", "<A-Down>", ":resize -2<CR>", opts)
keymap("n", "<A-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<A-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<Tab>", ":bnext<CR>", opts)
keymap("n", "<S-Tab>", ":bprevious<CR>", opts)
keymap("n", "<C-w>", ":bd<CR>", opts)

-- Insert --
-- Press jk fast to enter
keymap("i", ",,close_commandclose_commandclose_command", "<ESC>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Terminal --
-- Better terminal navigation
--[[ keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts) ]]
--[[ keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts) ]]
--[[ keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts) ]]
--[[ keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts) ]]

--
keymap("n", ",f", "<cmd>lua require'telescope.builtin'.find_files(require('telescope.themes').get_dropdown({ previewer = false }))<cr>", opts)
keymap("n", ",g", "<cmd>Telescope live_grep<cr>", opts)
--keymap("n", ",b", "<cmd>Telescope buffers<cr>", opts)

-- Nvimtree
keymap("n", "<space>e", ":NvimTreeToggle<cr>", opts)

keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)


--Enable completion triggered by <c-x><c-o>
--keymap("omnifunc", "v:lua.vim.lsp.omnifunc")
-- Mappings.
-- See `:help vim.lsp.*` for documentation on any of the below functions
--[[ keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts) ]]
--[[ keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts) ]]
--[[ --buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts) ]]
--[[ keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts) ]]
--[[ --buf_set_keymap('i', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts) ]]
--[[ keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts) ]]
--[[ keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts) ]]
--[[ keymap("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts) ]]
--[[ keymap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts) ]]
--[[ -- rename  ]]
--[[ keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts) ]]
--[[ -- Intelligent reminders , such as ： Automatic guiding package Has been used lspsaga The function in is replaced by  ]]
--[[ keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts) ]]
--[[ keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts) ]]
--[[ keymap("n", "<space>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts) ]]
--[[ --buf_set_keymap('n', '<C-j>', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts) ]]
--[[ -- ]]
--[[ keymap("n", "<S-C-j>", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts) ]]
--[[ -- Code formatting  ]]
--[[ keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts) ]]
--[[ keymap("n", "<leader>l", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts) ]]
--[[ keymap("n", "<leader>l", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts) ]]
--[[ -- Automatically import all missing packages , Automatically delete redundant and unused packages  ]]
--[[ keymap("n", "<A-o>", "<cmd>lua require'jdtls'.organize_imports()<CR>", opts) ]]
--[[ -- Functions that introduce local variables function to introduce a local variable ]]
--[[ keymap("n", "crv", "<cmd>lua require('jdtls').extract_variable()<CR>", opts) ]]
--[[ keymap("v", "crv", "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", opts) ]]
--[[ --function to extract a constant ]]
--[[ keymap("n", "crc", "<Cmd>lua require('jdtls').extract_constant()<CR>", opts) ]]
--[[ keymap("v", "crc", "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", opts) ]]
--[[ -- Extract a piece of code into an additional function function to extract a block of code into a method ]]
--[[ keymap("v", "crm", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", opts) ]]
