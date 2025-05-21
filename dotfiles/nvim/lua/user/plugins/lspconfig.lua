local M = {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    {
      "folke/neodev.nvim",
    },
  },
}

function M.config()
  local lspconfig = require "lspconfig"
  require("lspconfig.ui.windows").default_options.border = "rounded"
end

return M
