local M = {
  "andythigpen/nvim-coverage",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "VeryLazy",
}

function M.config()
  require("coverage").setup({
    auto_reload = true,
    lang = {
      typescript = {
        coverage_file = "coverage/lcov.info",
      },
      javascript = {
        coverage_file = "coverage/lcov.info",
      },
    },
  })

  -- Keymaps
  local keymap = vim.keymap.set
  local opts = { silent = true }

  keymap("n", "<leader>tc", "<cmd>Coverage<cr>", { desc = "Load coverage" })
  keymap("n", "<leader>tC", "<cmd>CoverageClear<cr>", { desc = "Clear coverage" })
  keymap("n", "<leader>ts", "<cmd>CoverageSummary<cr>", { desc = "Coverage summary" })
  keymap("n", "<leader>tt", "<cmd>CoverageToggle<cr>", { desc = "Toggle coverage" })
end

return M
