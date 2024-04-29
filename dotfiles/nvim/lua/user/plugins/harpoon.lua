local M = {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
}

function M.config()
  local harpoon = require "harpoon"

  -- REQUIRED
  harpoon:setup {
    settings = {
      save_on_toggle = true,
      sync_on_ui_close = false,
      -- key = function()
      --   local git = require "neogit.lib.git"
      --   local branch_name = git.branch.current_full_name()
      --   if branch_name == nil or branch_name == "" then
      --     -- Fallback to cwd if not in a git repository or branch name is not available
      --     return vim.loop.cwd()
      --   else
      --     return branch_name .. vim.loop.cwd()
      --   end
      -- end,
    },
  }
  -- REQUIRED

  vim.keymap.set("n", "<leader>a", function()
    harpoon:list():add()
  end)
  vim.keymap.set("n", "<C-e>", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
  end)

  vim.keymap.set("n", "<C-h>", function()
    harpoon:list():select(1)
  end)
  vim.keymap.set("n", "<C-j>", function()
    harpoon:list():select(2)
  end)
  vim.keymap.set("n", "<C-k>", function()
    harpoon:list():select(3)
  end)
  vim.keymap.set("n", "<C-l>", function()
    harpoon:list():select(4)
  end)
end

return M
