return {
  "Olical/conjure",
  ft = { "clojure", "fennel", "python" },
  config = function()
    require("conjure.main").main()
    require("conjure.mapping")["on-filetype"]()
  end,
  init = function()
    vim.g["conjure#mapping#doc_word"] = "K"
    vim.g["conjure#client#clojure#nrepl#connection#auto_repl#enabled"] = false
    vim.g["conjure#client#clojure#nrepl#eval#auto_require"] = false
  end,
}