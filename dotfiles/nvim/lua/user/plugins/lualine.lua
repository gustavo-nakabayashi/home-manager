local M = {
  "nvim-lualine/lualine.nvim",
}

function M.config()
  local sl_hl = vim.api.nvim_get_hl_by_name("StatusLine", true)
  vim.api.nvim_set_hl(0, "Copilot", { fg = "#6CC644", bg = sl_hl.background })
  local icons = require "user.icons"
  local diff = {
    "diff",
    colored = true,
    symbols = { added = icons.git.LineAdded, modified = icons.git.LineModified, removed = icons.git.LineRemoved }, -- Changes the symbols used by the diff.
  }

  -- local copilot = function()
  --   local buf_clients = vim.lsp.get_active_clients { bufnr = 0 }
  --   if #buf_clients == 0 then
  --     return "LSP Inactive"
  --   end
  --
  --   local buf_client_names = {}
  --   local copilot_active = false
  --
  --   for _, client in pairs(buf_clients) do
  --     if client.name ~= "null-ls" and client.name ~= "copilot" then
  --       table.insert(buf_client_names, client.name)
  --     end
  --
  --     if client.name == "copilot" then
  --       copilot_active = true
  --     end
  --   end
  --
  --   if copilot_active then
  --     return "%#Copilot#" .. icons.git.Octoface .. "%*"
  --   end
  --   return ""
  -- end

  -- local function basename(str)
  --   return string.gsub(str, "(.*/)(.*)", "%2")
  -- end
  -- define function and formatting of the information
  local function parrot_status()
    local status_info = require("parrot.config").get_status_info()
    local status = ""
    if status_info.is_chat then
      status = status_info.prov.chat.name
    else
      status = status_info.prov.command.name
    end
    return string.format("%s(%s)", status, status_info.model)
  end

  local function lualine_harpoon()
    local harpoon = require "harpoon"
    local keys = { "1", "2", "3", "4" }
    local currentfile = vim.fn.expand "%:t" -- Using ':t' modifier to get the basename

    local s = ""

    local statusline_fg = vim.api.nvim_get_hl_by_name("StatusLine", true).foreground
    local statusline_bg = vim.api.nvim_get_hl_by_name("StatusLine", true).background
    local lualine_a_fg = vim.api.nvim_get_hl_by_name("lualine_a_normal", true).foreground
    local lualine_a_bg = vim.api.nvim_get_hl_by_name("lualine_a_normal", true).background

    vim.api.nvim_set_hl(0, "EndActive", { bg = statusline_bg, fg = lualine_a_bg })
    vim.api.nvim_set_hl(0, "EndInactive", { bg = statusline_bg, fg = lualine_a_fg })

    for i, v in ipairs(harpoon:list().items) do
      local fn = vim.fn.fnamemodify(v.value, ":t") -- Using ':t' modifier within fnamemodify to get the basename
      if fn == currentfile then
        -- Item is active, use HarpoonActive highlight
        if i > 1 then
          s = s .. "%#lualine_a_normal#" .. "" .. keys[i] .. " " .. fn
        else
          s = s .. "%#lualine_a_normal#" .. " " .. keys[i] .. " " .. fn
        end

        if i < #harpoon:list().items then
          s = s .. "%#lualine_b_normal#" .. ""
        else
          s = s .. "%#EndActive#" .. ""
        end
      else
        -- Item is inactive, use HarpoonInactive highlight
        s = s .. "%#lualine_b_normal#" .. " " .. keys[i] .. " " .. fn

        if i >= #harpoon:list().items then
          s = s .. "%#EndInactive#" .. ""
        else
          s = s .. " "
        end
      end
    end

    if #harpoon:list().items == 0 then
      s = "%#lualine_b_normal#" .. "󰛢" -- Using HarpoonInactive highlight for consistency
    end

    return s .. "%#StatusLine#" -- Reset to normal highlighting at the end
  end

  require("lualine").setup {
    options = {
      -- component_separators = { left = "", right = "" },
      -- section_separators = { left = "", right = "" },
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      ignore_focus = { "NvimTree" },
    },
    tabline = {

      -- lualine_a = { lualine_harpoon },
      -- lualine_a = {},
      -- lualine_b = {},
      -- lualine_c = {},
      -- lualine_x = {},
      -- lualine_y = {},
      -- lualine_z = {},
    },
    sections = {
      -- lualine_a = { {"branch", icon =""} },
      -- lualine_b = { diff },
      -- lualine_c = { "diagnostics" },
      -- lualine_x = { copilot },
      -- lualine_y = { "filetype" },
      -- lualine_z = { "progress" },
      lualine_a = { "mode", parrot_status },
      lualine_b = { "filename" },
      lualine_c = { "diagnostics" },
      lualine_x = { diff, "branch" },
      lualine_y = { "filetype" },
      lualine_z = { "progress" },
    },
    extensions = { "quickfix", "man", "fugitive" },
  }
end

return M
