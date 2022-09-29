local notify = require('notify')

notify.setup({
    timeout = 2000,
    on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 2000 })
    end,
})

vim.notify = notify
