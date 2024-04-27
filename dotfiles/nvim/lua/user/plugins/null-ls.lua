local M = {
  "jose-elias-alvarez/null-ls.nvim",
}

function M.config()
  local null_ls = require "null-ls"

  local formatting = null_ls.builtins.formatting

  local diagnostics = null_ls.builtins.diagnostics
  local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

  null_ls.setup {
    sources = {
      formatting.stylua,
      formatting.prettier.with {
        extra_filetypes = { "toml", "liquid" },
      },
      formatting.black.with { extra_args = { "--fast" } },
      formatting.google_java_format,
      formatting.gofumpt,
      formatting.goimports_reviser,
      diagnostics.eslint,
    },
  }
end

return M
