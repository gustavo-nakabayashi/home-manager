local M = {
  "ThePrimeagen/99",
}

function M.config()
  local _99 = require("99")

  local cwd = vim.uv.cwd()
  local basename = vim.fs.basename(cwd)

  _99.setup({
    provider = require("99.providers").ClaudeCodeProvider,

    logger = {
      level = _99.DEBUG,
      path = "/tmp/" .. basename .. ".99.debug",
      print_on_error = true,
    },

    completion = {
      custom_rules = {
        "scratch/custom_rules/",
      },
      source = "cmp",
    },

    md_files = {
      "CLAUDE.md",
    },
  })

  vim.keymap.set("n", "<leader>9f", function()
    _99.fill_in_function()
  end)

  vim.keymap.set("v", "<leader>9v", function()
    _99.visual()
  end)

  vim.keymap.set("v", "<leader>9s", function()
    _99.stop_all_requests()
  end)
end

return M
