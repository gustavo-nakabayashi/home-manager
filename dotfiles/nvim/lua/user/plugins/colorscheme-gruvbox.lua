local M = {
  -- "sainnhe/gruvbox-material",
  "ellisonleao/gruvbox.nvim",
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  enable = true
}

function M.config()
  require("gruvbox").setup {}
  vim.o.background = "light" -- or "light" for light mode
  vim.cmd("colorscheme gruvbox")
end

return M
