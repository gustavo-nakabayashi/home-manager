return {
  "PaterJason/nvim-treesitter-sexp",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  ft = { "clojure", "fennel", "scheme", "lisp" },
  config = function()
    require("treesitter-sexp").setup({
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aF"] = "@call.outer",
        ["iF"] = "@call.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
        ["av"] = "@assignment.outer",
        ["iv"] = "@assignment.inner",
        ["ai"] = "@conditional.outer",
        ["ii"] = "@conditional.inner",
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
        ["aC"] = "@comment.outer",
        ["iC"] = "@comment.inner",
      },
    })
  end,
}