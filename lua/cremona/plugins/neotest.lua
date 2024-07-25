return {
  "nvim-neotest/neotest",
  dependencies = {
    'nvim-neotest/neotest-jest',
    "rcasia/neotest-java",
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter"
  },
  config = function()
    local neotest = require("neotest")

    neotest.setup({
      adapters = {
        require("neotest-java")({
          ignore_wrapper = false, -- whether to ignore maven/gradle wrapper
          junit_jar = nil,
          -- default: .local/share/nvim/neotest-java/junit-platform-console-standalone-[version].jar
        }),
        require('neotest-jest')({
          jestCommand = "npm test --",
          jestConfigFile = "custom.jest.config.ts",
          env = { CI = true},
          cwd = function()
          return vim.fn.getcwd()
          end,
        }),
      }
    })
  end,

}
