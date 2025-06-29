return {
  url = "https://gitlab.com/schrieveslaach/sonarlint.nvim",
  ft = { "javascript", "typescript", "typescriptreact" },
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  config = function()
    require("sonarlint").setup {
      server = {
        cmd = {
          "sonarlint-ls",
          -- Ensure that sonarlint-language-server uses stdio channel
          "-stdio",
          "-analyzers",
          -- paths to the analyzers you need, using those for python and java in this example
          vim.fn.expand "$SONAR_LINT_HOME/share/plugins/sonarjs.jar",
        },
      },
      filetypes = {
        "javascript",
        "typescript",
        "typescriptreact",
        "css",
      },
    }
  end,
}
