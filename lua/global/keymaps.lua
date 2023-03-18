M = {}

-- vim.g.mapleader = 'space'
-- vim.g.maplocalleader = 'space'

local opts = { noremap = true, silent = true }
-- For the description on keymaps, I have a function getOptions(desc) which returns noremap=true, silent=true and desc=desc. Then call: keymap(mode, keymap, command, getOptions("some randome desc")

local keymap = vim.keymap.set

-- Insert --
keymap("i", "<C-c>", "<Esc>", opts)

-- Normal --
keymap("n", "<C-Space>", "<cmd>WhichKey \\<space><cr>", opts)
-- keymap("n", "<C-i>", "<C-i>", opts)


keymap("n", "tt", "zt", opts)


-- copia a linha inteira sem pular de linha
keymap("n", "<C-y>", "_v$y", opts)

keymap("n", "<C-t>", "<cmd>:terminal<cr>i", opts)


keymap("n", ",at", "vat=<C-o>", opts)
keymap("n", ",af", "va{=<C-o>", opts)

keymap("n", "<Space>df", "Vf{%d", opts)
keymap("n", "<Space>yf", "Vf{%y", opts)


-- Better window navigation
keymap("n", "<m-h>", "<C-w>h", opts)
keymap("n", "<m-j>", "<C-w>j", opts)
keymap("n", "<m-k>", "<C-w>k", opts)
keymap("n", "<m-l>", "<C-w>l", opts)
keymap("n", "<m-tab>", "<c-6>", opts)

-- Tabs --
-- keymap("n", "\\", ":tabnew %<cr>", opts)
-- keymap("n", "\\", ":tabnew %<cr>", opts)
-- keymap("n", "<s-\\>", ":tabclose<cr>", opts)
-- keymap("n", "<s-\\>", ":tabonly<cr>", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

keymap("v", "p", '"_dP', opts)
-- keymap("v", "P", '"_dP', opts)

keymap("n", "Q", "<cmd>Bdelete!<CR>", opts)

keymap(
  "n",
  "<F6>",
  [[:echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">" . " FG:" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"fg#")<CR>]],
  opts
)
keymap("n", "<F7>", "<cmd>TSHighlightCapturesUnderCursor<cr>", opts)
-- keymap("n", "<C-z>", "<cmd>ZenMode<cr>", opts)
keymap("n", "-", ":lua require'lir.float'.toggle()<cr>", opts)
keymap("n", "gx", [[:silent execute '!$BROWSER ' . shellescape(expand('<cfile>'), 1)<CR>]], opts)
keymap("n", "<m-v>", "<cmd>lua require('lsp_lines').toggle()<cr>", opts)

keymap("n", "<m-/>", "<cmd>lua require('Comment.api').toggle_current_linewise()<CR>", opts)
keymap("x", "<m-/>", '<ESC><CMD>lua require("Comment.api").toggle_linewise_op(vim.fn.visualmode())<CR>', opts)

vim.api.nvim_set_keymap(
  "n",
  "<A-t>",
  "<cmd>lua require('telescope').extensions.harpoon.marks(require('telescope.themes').get_dropdown{previewer = false, initial_mode='normal', prompt_title='Harpoon'})<cr>",
  opts
)
vim.api.nvim_set_keymap(
  "n",
  "<s-tab>",
  "<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown{previewer = false, initial_mode='normal'})<cr>",
  opts
)

vim.cmd [[
  function! QuickFixToggle()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
      copen
    else
      cclose
    endif
  endfunction
]]

keymap("n", "<m-q>", ":call QuickFixToggle()<cr>", opts)

-- keymap("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", opts)
-- keymap("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>", opts)

M.show_documentation = function()
  local filetype = vim.bo.filetype
  if vim.tbl_contains({ "vim", "help" }, filetype) then
    vim.cmd("h " .. vim.fn.expand "<cword>")
  elseif vim.tbl_contains({ "man" }, filetype) then
    vim.cmd("Man " .. vim.fn.expand "<cword>")
  elseif vim.fn.expand "%:t" == "Cargo.toml" then
    require("crates").show_popup()
  else
    vim.lsp.buf.hover()
  end
end
vim.api.nvim_set_keymap("n", "K", ":lua require('user.keymaps').show_documentation()<CR>", opts)

-- Nvimtree
keymap("n", "<space>e", "<cmd>NvimTreeToggle<cr>", opts)

-- Harpoon
keymap("n", "<A-y>", "<cmd>lua require('harpoon.mark').add_file()<cr>", opts)

keymap("n", "<A-u>", "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", opts)
keymap("n", "<A-i>", "<cmd>lua require('harpoon.ui').nav_file(2)<cr>", opts)
keymap("n", "<A-o>", "<cmd>lua require('harpoon.ui').nav_file(3)<cr>", opts)
keymap("n", "<A-p>", "<cmd>lua require('harpoon.ui').nav_file(4)<cr>", opts)

-- Navigate buffers
keymap("n", "<Tab>", ":bnext<CR>", opts)
keymap("n", "<S-Tab>", ":bprevious<CR>", opts)
keymap("n", "<C-w>", ":bd<CR>", opts)

-- Telescope
keymap("n", ",f", "<cmd>Telescope find_files<cr>", opts)
keymap("n", ",g", "<cmd>Telescope live_grep<cr>", opts)
keymap("n", "gr", "<cmd>lua require('telescope.builtin').lsp_references()<cr>", opts)
keymap("n", ",d", "<cmd>lua require('telescope.builtin').diagnostics()<cr>", opts)

-- LSP
keymap("n", "<C-A-n>", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR> <cmd>CodeActionMenu<CR> ", opts)
keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
keymap("n", "<S-k>", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
-- keymap("n", "td", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
keymap("n", "<C-A-r>", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
-- keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
-- keymap("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
-- keymap("n", "<C-A-e>", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)

-- JDTLS
keymap("n", "<C-A-o>", "<Cmd>lua require'jdtls'.organize_imports()<CR>", opts)




-- keymap("n", "<C-A-n>", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR>  <cmd>lua vim.lsp.buf.code_action()<cr> ", opts)
-- keymap("n", "<leader>wl", "<cmd> print(lua vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>", opts)

return M
