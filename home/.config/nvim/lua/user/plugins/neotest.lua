local M = {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "marilari88/neotest-vitest",
  },
  event = "VeryLazy",
}

function M.config()
  local neotest = require("neotest")

  neotest.setup({
    adapters = {
      require("neotest-vitest"),
    },
  })

  -- Keymaps
  local keymap = vim.keymap.set
  keymap("n", "<leader>tt", function() neotest.run.run() end, { desc = "Run nearest test" })
  keymap("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Run current file" })
  keymap("n", "<leader>ta", function() neotest.run.run(vim.fn.getcwd()) end, { desc = "Run all tests" })
  keymap("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = "Toggle test summary" })
  keymap("n", "<leader>to", function() neotest.output.open({ enter = true }) end, { desc = "Show test output" })
  keymap("n", "<leader>tp", function() neotest.output_panel.toggle() end, { desc = "Toggle output panel" })
  keymap("n", "<leader>tS", function() neotest.run.stop() end, { desc = "Stop test" })
end

return M
