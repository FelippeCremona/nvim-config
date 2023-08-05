local luasnip = require'luasnip'
local cmp = require'cmp'
local cmp_autopairs = require('nvim-autopairs.completion.cmp')

require("luasnip.loaders.from_vscode").lazy_load()

-- cmp.event:on(
--   'confirm_done',
--   cmp_autopairs.on_confirm_done()
-- )
local handlers = require('nvim-autopairs.completion.handlers')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  -- window = {
  --   completion = cmp.config.window.bordered(),
  --   documentation = cmp.config.window.bordered(),
  -- },
  experimental = {
    ghost_text = true,
    native_menu = false,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-j>'] = function()
      local active = cmp.get_active_entry()
      if active then
        return cmp.close()
      end
      local next = '<Cmd>lua require("cmp").select_next_item()<CR>'
      local prev = '<Cmd>lua require("cmp").select_prev_item()<CR>'
      local close = '<Cmd>lua require("cmp").close()<CR>'
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(next .. prev .. close, true, true, true), 'n', true)
    end,
  }),
  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = function(entry, vim_item)
      -- Kind icons
      -- vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
      -- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
      vim_item.menu = ({
        nvim_lsp = "[LSP]",
        luasnip = "[Snippet]",
        buffer = "[Buffer]",
        path = "[Path]",
      })[entry.source.name]
      return vim_item
    end,
  },
  confirm_opts = {
    behavior = cmp.ConfirmBehavior.Replace,
    select = false,
  },
  -- sources = cmp.config.sources({
  --   { name = 'nvim_lsp' },
  --   { name = 'nvim_lua' },
  --   { name = 'path' },
  --   { name = 'luasnip' },
  --   { name = 'buffer' },
  -- }),

-- You should specify your *installed* sources.
  sources = {
    { name = 'buffer' },
  },
  enabled = function()
    return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt"
        or require("cmp_dap").is_dap_buffer()
  end
})

cmp.setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
  sources = {
    { name = "dap" },
  },
})

cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done({
    filetypes = {
      -- "*" is a alias to all filetypes
      ["*"] = {
        ["("] = {
          kind = {
            cmp.lsp.CompletionItemKind.Function,
            cmp.lsp.CompletionItemKind.Method,
          },
          handler = handlers["*"]
        }
      },
      lua = {
        ["("] = {
          kind = {
            cmp.lsp.CompletionItemKind.Function,
            cmp.lsp.CompletionItemKind.Method
          },
          handler = handlers["*"]            -- Your handler function. Inpect with print(vim.inspect{char, item, bufnr, rules, commit_character})
        }
      },
      -- Disable for tex
      tex = false
    }
  })
)


