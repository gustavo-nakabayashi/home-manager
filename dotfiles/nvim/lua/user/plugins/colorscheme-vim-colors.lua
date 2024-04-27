local M = {
  "cormacrelf/vim-colors-github",
  lazy = false,    -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
}

vim.g.github_colors_soft = 1

return M
