local M = {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      event = "VeryLazy",
    },
    {
      "JoosepAlviste/nvim-ts-context-commentstring",
      event = "VeryLazy",
    },
    {
      "RRethy/nvim-treesitter-textsubjects",
      event = "VeryLazy",
    },
  },
}
function M.config()
  -- local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
  -- parser_config.html.filetype = { 'astro', 'html', 'liquid' }

  -- vim.treesitter.language.register('html', 'liquid')  -- the someft filetype will use the python parser and queries.

  ---@diagnostic disable-next-line: missing-fields
  require("nvim-treesitter.configs").setup {
    ensure_installed = {
      "bash",
      "c",
      "go",
      "javascript",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "nix",
      "python",
      "terraform",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
    }, -- put the language you want in this array
    ignore_install = { "" },
    sync_install = false,
    highlight = {
      enable = true,
      disable = { "markdown", "vimdoc" },
    },

    indent = { enable = true },

    matchup = {
      enable = false,
      disable = { "lua", "liquid", "html", "javascript", "javascriptreact" },
    },


    custom_captures = {
      -- Highlight the @foo.bar capture group with the "Identifier" highlight group.
      ["Statement"] = "#FF0000",
    },

    textobjects = {
      select = {
        enable = true,
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
        },
      },
    },
    textsubjects = {
      enable = true,
      prev_selection = ",", -- (Optional) keymap to select the previous selection
      keymaps = {
        ["."] = "textsubjects-smart",
        [";"] = "textsubjects-container-outer",
        ["i;"] = "textsubjects-container-inner",
        ["i;"] = { "textsubjects-container-inner", desc = "Select inside containers (classes, functions, etc.)" },
      },
    },
  }
end

return M
