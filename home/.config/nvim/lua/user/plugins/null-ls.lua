local M = {
  "nvimtools/none-ls.nvim",
}

function M.config()
  local null_ls = require "null-ls"

  local formatting = null_ls.builtins.formatting

  local diagnostics = null_ls.builtins.diagnostics
  local code_actions = null_ls.builtins.code_actions
  local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

  null_ls.setup {
    sources = {
      formatting.stylua,
      -- formatting.eslint,
      formatting.prettier.with {
        extra_filetypes = { "toml", "liquid", "typescriptreact" },
      },
      formatting.black.with { extra_args = { "--fast" } },
      formatting.google_java_format,
      formatting.gofumpt,
      formatting.goimports_reviser,
      formatting.alejandra,
      formatting.cljfmt.with { extra_args = {  "--function-arguments-indentation", "cursive" } },
      -- diagnostics.eslint,
      -- code_actions.eslint
      diagnostics.clj_kondo,
    },
  }
end

return M
