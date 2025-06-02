local M = {
  "shaunsingh/solarized.nvim",
  lazy = false,    -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
}

function M.config()
  vim.g.solarized_contrast = false
  vim.o.background = "light"
  require('solarized').set()
end


return M
