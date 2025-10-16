local M = {
  "coder/claudecode.nvim",
  event = "VeryLazy",
  dependencies = { "folke/snacks.nvim" },
}

function M.config()
  require('claudecode').setup({
    git_repo_cwd = true,
    terminal = {
      split_side = "right",
      provider = "auto",
    },
  })

  -- Keymaps
  local keymap = vim.keymap.set
  local opts = { silent = true }

  keymap("n", "<leader>cc", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude Code" })
  keymap("n", "<leader>co", "<cmd>ClaudeCodeOpen<cr>", { desc = "Open Claude Code" })
  keymap("n", "<leader>cq", "<cmd>ClaudeCodeClose<cr>", { desc = "Close Claude Code" })
end

return M
