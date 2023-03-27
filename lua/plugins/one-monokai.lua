require("one_monokai").setup({
    transparent = true,  -- enable transparent window
    colors = {
        lmao = "#111214", -- add new color
        pink = "#ec6075", -- replace default color
    },
    themes = function(colors)
        -- change highlight of some groups,
        -- the key and value will be passed respectively to "nvim_set_hl"
        return {
            Normal = { bg = colors.lmao },
            ErrorMsg = { fg = colors.pink, bg = "#ec6075", standout = true },
            ["@lsp.type.keyword"] = { link = "@keyword" }
        }
    end,
})
