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
-- gd "esperto": tenta a definição normal do LSP (mesma lógica de agregação
-- multi-cliente que o vim.lsp.buf.definition() nativo usa: buf_request_all,
-- que só decide depois que TODOS os clientes responderem — a versão anterior
-- usava buf_request simples, que reagia ao primeiro cliente a responder e
-- quebrava a navegação normal quando havia mais de um cliente no buffer).
-- Se nada for encontrado: em .js cai pro goto_service_method, em .html
-- cai pro ,c (goto_html_controller_member).
local function smart_goto_definition_fallback()
  local ft = vim.bo.filetype
  if ft == "javascript" or ft == "javascriptreact" then
    require("cremona.angularjs_goto").goto_service_method()
  elseif ft == "html" then
    require("cremona.angularjs_goto").goto_html_controller_member()
  else
    vim.notify("Definição não encontrada", vim.log.levels.WARN)
  end
end

local function smart_goto_definition()
  local bufnr = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local method = "textDocument/definition"

  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = method })
  if vim.tbl_isempty(clients) then
    smart_goto_definition_fallback()
    return
  end

  vim.lsp.buf_request_all(bufnr, method, function(client)
    return vim.lsp.util.make_position_params(win, client.offset_encoding)
  end, function(results)
    local all_items = {}
    for client_id, res in pairs(results) do
      local client = vim.lsp.get_client_by_id(client_id)
      if client and res and res.result then
        local locations = vim.islist(res.result) and res.result or { res.result }
        local items = vim.lsp.util.locations_to_items(locations, client.offset_encoding)
        vim.list_extend(all_items, items)
      end
    end

    if vim.tbl_isempty(all_items) then
      smart_goto_definition_fallback()
      return
    end

    if #all_items == 1 then
      local item = all_items[1]
      local b = item.bufnr or vim.fn.bufadd(item.filename)
      vim.cmd("normal! m'")
      vim.bo[b].buflisted = true
      vim.api.nvim_win_set_buf(win, b)
      vim.api.nvim_win_set_cursor(win, { item.lnum, item.col - 1 })
      vim.cmd("normal! zvzz")
    else
      vim.fn.setqflist({}, ' ', { title = 'LSP locations', items = all_items })
      vim.cmd('botright copen')
    end
  end)
end

keymap("n", "gd", smart_goto_definition, opts)
keymap('n','K','<cmd>lua vim.lsp.buf.hover()<CR>')
keymap('n','gs','<cmd>lua vim.lsp.buf.signature_help()<CR>')
keymap('n','gi','<cmd>lua vim.lsp.buf.implementation()<CR>')
keymap('n','gt','<cmd>lua vim.lsp.buf.type_definition()<CR>')
keymap('n','<space>gw','<cmd>lua vim.lsp.buf.document_symbol()<CR>')
keymap('n','<space>gW','<cmd>lua vim.lsp.buf.workspace_symbol()<CR>')
-- keymap('n',',af','<cmd>lua vim.lsp.buf.code_action()<CR>')
keymap('n','<C-A-r>','<cmd>lua vim.lsp.buf.rename()<CR>')
keymap('n','<space>ai','<cmd>lua vim.lsp.buf.incoming_calls()<CR>')
keymap('n','<space>ao','<cmd>lua vim.lsp.buf.outgoing_calls()<CR>')

keymap("n", "<C-A-o>", "<Cmd>lua require'jdtls'.organize_imports()<CR>", opts)
-- keymap("n", "<C-A-n>", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR> <cmd>CodeActionMenu<CR> ", opts)
keymap("n", "<C-A-n>", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR> <cmd>lua vim.lsp.buf.code_action()<CR> ", opts)
keymap("n", "<C-A-N>", "<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR, buffer=0})<CR> <cmd>lua vim.lsp.buf.code_action()<CR> ", opts)

-- Atalhos JDTLS
-- keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)

-- Atalhos DAP
keymap('n', '<space>dt', ':lua require("dap").toggle_breakpoint()<CR>')
keymap('n', '<F1>', ':lua require("dap.ui.widgets").centered_float(require("dap.ui.widgets").frames)<CR>')
keymap({'n' }, '<F2>', ':lua require("dap.ui.widgets").hover()<CR>')
keymap('v', '<F2>', function() require("dapui").eval() end)
keymap('n', '<F3>', ':lua require"dap".repl.toggle({height=8})<CR>')
keymap('n', '<F4>', ':lua require"dap.ui.widgets".centered_float(require"dap.ui.widgets".scopes)<CR>')
keymap('n', '<F8>', ':lua require"dap".continue()<CR>')
keymap('n', '<F10>', ':lua require"dap".step_over()<CR>')
keymap('n', '<F11>', ':lua require"dap".step_into()<CR>')
keymap('n', '<S-F11>', ':lua require"dap".step_out()<CR>')
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
