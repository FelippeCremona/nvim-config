-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Impede que o Telescope abra um buffer em modo de inclusao
vim.api.nvim_create_autocmd("WinLeave", {
  callback = function()
    if vim.bo.ft == "TelescopePrompt" and vim.fn.mode() == "i" then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "i", false)
    end
  end,
})

-- Destaque a variável sob o cursor após o LSP iniciar
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf

    -- LspAttach dispara uma vez por cliente que anexa ao buffer (ex: html +
    -- outro servidor no mesmo arquivo); sem essa guarda, os autocmds abaixo
    -- ficavam duplicados a cada cliente novo.
    if vim.b[bufnr].cursor_highlight_autocmds_set then
      return
    end
    vim.b[bufnr].cursor_highlight_autocmds_set = true

    vim.api.nvim_create_autocmd({'CursorHold', 'CursorHoldI'}, {
      buffer = bufnr,
      callback = function()
        -- Nem todo servidor suporta documentHighlight (ex: o do html) —
        -- chamar sem checar isso dá erro no CursorHold.
        if #vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/documentHighlight' }) > 0 then
          vim.lsp.buf.document_highlight()
        end
      end,
    })
    vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.clear_references()
      end,
    })
  end,
})
