return {
  "guns/vim-sexp",
  ft = { "clojure", "fennel", "scheme", "lisp" },
  dependencies = {
    {
      "tpope/vim-sexp-mappings-for-regular-people",
      ft = { "clojure", "fennel", "scheme", "lisp" },
    },
  },
  config = function()
    vim.g.sexp_enable_insert_mode_mappings = 0
    vim.g.sexp_filetypes = "clojure,scheme,lisp,timl,fennel"
  end,
}