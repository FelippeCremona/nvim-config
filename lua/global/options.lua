-- vim.opt.fillchars = vim.opt.fillchars + 'eob: '
-- vim.opt.fillchars:append {
--   stl = ' ',
-- }
--
-- vim.opt.shortmess:append "c"
--
-- vim.cmd "set whichwrap+=<,>,[,],h,l"
-- vim.cmd [[set iskeyword+=-]]
-- vim.cmd [[set formatoptions-=cro]] -- TODO: this doesn't seem to work
--
-- vim.filetype.add {
--   extension = {
--     conf = "dosini",
--   },
-- }
--
vim.g.clipboard = {
   name = 'WslClipboard',
   copy = {
      ['+'] = 'clip.exe',
      ['*'] = 'clip.exe',
   },
   paste = {
      ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
   },
   cache_enabled = 0,
}

vim.g.python3_host_prog = '/usr/bin/python3.9'

-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 0
vim.g.loaded_netrwPlugin = 0

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true


-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'

-- Set colorscheme
vim.o.termguicolors = true
vim.cmd [[colorscheme monokai_pro]]

-- Set completeopt to have a better completion experience
-- vim.o.completeopt = 'menuone,noselect'
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
-- vim.o.clipboard = "unnamedplus"

local options = {
  backup = false,                          -- creates a backup file
  clipboard = {"unnamed", "unnamedplus"},                   -- allows neovim to access the system clipboard
  cmdheight = 0,                           -- more space in the neovim command line for displaying messages
  completeopt = { "menuone", "noselect" }, -- mostly just for cmp
  conceallevel = 0,                        -- so that `` is visible in markdown files fileencoding = "utf-8",                   -- the encoding written to a file
  hlsearch = true,                         -- highlight all matches on previous search pattern
  ignorecase = true,                       -- ignore case in search patterns
  mouse = "a",                             -- allow the mouse to be used in neovim
  pumheight = 10,                          -- pop up menu height
  showmode = false,                        -- we don't need to see things like -- INSERT -- anymore
  showtabline = 0,                         -- always show tabs
  smartcase = true,                        -- smart case
  smartindent = true,                      -- make indenting smarter again
  splitbelow = true,                       -- force all horizontal splits to go below current window
  splitright = true,                       -- force all vertical splits to go to the right of current window
  swapfile = false,                        -- creates a swapfile
  termguicolors = true,                    -- set term gui colors (most terminals support this)
  timeoutlen = 1000,                       -- time to wait for a mapped sequence to complete (in milliseconds)
  undofile = true,                         -- enable persistent undo
  updatetime = 40,                         -- faster completion (4000ms default)
  writebackup = false,                     -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
  expandtab = true,                        -- convert tabs to spaces
  shiftwidth = 2,                          -- the number of spaces inserted for each indentation
  tabstop = 2,                             -- insert 2 spaces for a tab
  cursorline = true,                       -- highlight the current line
  number = true,                           -- set numbered lines
  laststatus = 3,
  showcmd = false,
  ruler = false,
  relativenumber = true, -- set relative numbered lines
  numberwidth = 2,       -- set number column width to 2 {default 4}
  signcolumn = "yes",    -- always show the sign column, otherwise it would shift the text each time
  wrap = false,          -- display lines as one long line
  scrolloff = 0,
  sidescrolloff = 8,
  guifont = "monospace:h17", -- the font used in graphical neovim applications
  title = true,
}

for k, v in pairs(options) do
  vim.opt[k] = v
end
