local M = {
  "lukas-reineke/indent-blankline.nvim",
  event = "VeryLazy",
  main="ibl"
}

function M.config()
  require("ibl").setup {
    indent = {
      char = "│",
      tab_char = "│",
    },
    exclude = {
      buftypes ={ "terminal", "nofile" },
      filetypes= {
        "help",
        "startify",
        "dashboard",
        "lazy",
        "neogitstatus",
        "NvimTree",
        "Trouble",
        "text",
      }
    },
  }
end

return M
