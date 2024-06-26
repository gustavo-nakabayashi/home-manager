local M = {
  "nvim-neorg/neorg",
  build = ":Neorg sync-parsers",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("neorg").setup {
      load = {
        ["core.defaults"] = {}, -- Loads default behaviour
        ["core.concealer"] = {
          config = {
            icon_preset = "diamond"
          }
        }, -- Adds pretty icons to your documents
        ["core.keybinds"] = {},
        ["core.dirman"] = { -- Manages Neorg workspaces
          config = {
            workspaces = {
              notes = "~/notes",
            },
            use_popup = false,
          },
        },
      },
    }
  end,
}

return M
