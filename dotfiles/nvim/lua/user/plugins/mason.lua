local M = {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "nvim-lua/plenary.nvim",
  },
}

local servers = {
  "lua_ls",
  "cssls",
  "html",
  "tsserver",
  -- "astro",
  -- "pyright",
  "bashls",
  "jsonls",
  "yamlls",
  "marksman",
  "eslint",
  -- "elixirls",
  -- "tailwindcss",
}

function M.config()
  require("mason").setup {
    ui = {
      border = "rounded",
    },
  }
  require("mason-lspconfig").setup {
    ensure_installed = servers,
  }
end

return M
