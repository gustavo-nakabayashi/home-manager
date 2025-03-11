local M = {
  "folke/which-key.nvim",
  event = "VeryLazy",
}

function M.config()
  local mappings = {
    mode = { "n" },
    { "<leader>q", "<cmd>confirm q<CR>", desc = "Quit" },
    { "<leader>/", "<Plug>(comment_toggle_linewise_current)", desc = "Comment" },
    { "<leader>h", "<cmd>nohlsearch<CR>", desc = "No Highlight" },
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Explorer" },
    -- ["e"] = { "<cmd>Neotree toggle<CR>", "Explorer" },

    { "<leader>b", group = "Buffers" },
    { "<leader>bb", "<cmd>Telescope buffers previewer=false<cr>", desc = "Find" },

    { "<leader>p", group = "Plugins" },
    { "<leader>pi", "<cmd>Lazy install<cr>", desc = "Install" },
    { "<leader>ps", "<cmd>Lazy sync<cr>", desc = "Sync" },
    { "<leader>pS", "<cmd>Lazy clear<cr>", desc = "Status" },
    { "<leader>pc", "<cmd>Lazy clean<cr>", desc = "Clean" },
    { "<leader>pu", "<cmd>Lazy update<cr>", desc = "Update" },
    { "<leader>pp", "<cmd>Lazy profile<cr>", desc = "Profile" },
    { "<leader>pl", "<cmd>Lazy log<cr>", desc = "Log" },
    { "<leader>pd", "<cmd>Lazy debug<cr>", desc = "Debug" },

    { "<leader>f", group = "Find" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fc", "<cmd>Telescope colorscheme<cr>", desc = "Colorscheme" },
    {
      "<leader>ff",
      "<cmd>lua require'telescope.builtin'.find_files({ find_command = {'fd', '--type', 'f', '--hidden', '--no-require-git', '--exclude', '.git' }})<cr>",
      desc = "Find files",
    },
    { "<leader>fp", "<cmd>lua require('telescope').extensions.projects.projects()<cr>", desc = "Projects" },
    { "<leader>ft", "<cmd>Telescope live_grep<cr>", desc = "Find Text" },
    { "<leader>fs", "<cmd>Telescope grep_string<cr>", desc = "Find String" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
    { "<leader>fH", "<cmd>Telescope highlights<cr>", desc = "Highlights" },
    { "<leader>fi", "<cmd>lua require('telescope').extensions.media_files.media_files()<cr>", desc = "Media" },
    { "<leader>fl", "<cmd>Telescope resume<cr>", desc = "Last Search" },
    { "<leader>fM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent File" },
    { "<leader>fR", "<cmd>Telescope registers<cr>", desc = "Registers" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
    { "<leader>fC", "<cmd>Telescope commands<cr>", desc = "Commands" },
    { "<leader>fg", "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", desc = "RipGrep" },
    {
      "<leader>fw",
      "<cmd>lua require 'telescope-live-grep-args.shortcuts'.grep_word_under_cursor()<cr>",
      desc = "RipGrep",
    },

    { "<leader>g", group = "Git" },
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    { "<leader>gj", "<cmd>lua require 'gitsigns'.next_hunk({navigation_message = false})<cr>", desc = "Next Hunk" },
    { "<leader>gk", "<cmd>lua require 'gitsigns'.prev_hunk({navigation_message = false})<cr>", desc = "Prev Hunk" },
    { "<leader>gl", "<cmd>lua require 'gitsigns'.blame_line()<cr>", desc = "Blame" },
    { "<leader>gp", "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", desc = "Preview Hunk" },
    { "<leader>gr", "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", desc = "Reset Hunk" },
    { "<leader>gR", "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", desc = "Reset Buffer" },
    { "<leader>gs", "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", desc = "Stage Hunk" },
    { "<leader>gS", "<cmd>lua require 'gitsigns'.stage_buffer()<cr>", desc = "Stage Buffer" },
    { "<leader>gu", "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", desc = "Undo Stage Hunk" },
    { "<leader>go", "<cmd>Telescope git_status<cr>", desc = "Open changed file" },
    { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Checkout branch" },
    { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Checkout commit" },
    { "<leader>gC", "<cmd>Telescope git_bcommits<cr>", desc = "Checkout commit(for current file)" },
    {
      "<leader>gd",
      function()
        if next(require("diffview.lib").views) == nil then
          vim.cmd "DiffviewOpen"
        else
          vim.cmd "DiffviewClose"
        end
      end,
      desc = "Git Diff",
    },

    { "<leader>l", group = "LSP" },
    { "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code Action" },
    { "<leader>ld", "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", desc = "Buffer Diagnostics" },
    { "<leader>lw", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
    { "<leader>lf", "<cmd>lua vim.lsp.buf.format({timeout_ms = 1000000})<cr>", desc = "Format" },
    { "<leader>li", "<cmd>LspInfo<cr>", desc = "Info" },
    { "<leader>lI", "<cmd>Mason<cr>", desc = "Mason Info" },
    { "<leader>lj", "<cmd>lua vim.diagnostic.goto_next()<cr>", desc = "Next Diagnostic" },
    { "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev()<cr>", desc = "Prev Diagnostic" },
    { "<leader>ll", "<cmd>lua vim.lsp.codelens.run()<cr>", desc = "CodeLens Action" },
    { "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<cr>", desc = "Quickfix" },
    { "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename" },
    { "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols" },
    { "<leader>lS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Workspace Symbols" },
    { "<leader>le", "<cmd>Telescope quickfix<cr>", desc = "Telescope Quickfix" },
    { "<leader>lR", "<cmd>LspRestart<cr>", desc = "LSP Restart" },

    { "<leader>t", group = "Trouble" },
    { "<leader>tt", "<cmd>TroubleToggle<cr>", desc = "Document Symbols" },

    { "<leader>T", group = "Treesitter" },
    { "<leader>Ti", ":TSConfigInfo<cr>", desc = "Info" },
  }

  -- NOTE: Prefer using : over <cmd> as the latter avoids going back in normal-mode.
  -- see https://neovim.io/doc/user/map.html#:map-cmd
  local vmappings = {
    mode = { "v" },
    { "<leader>/", "<Plug>(comment_toggle_linewise_visual)", desc = "Comment toggle linewise (visual)" },

    { "<leader>l", group = "LSP" },
    { "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code Action" },

    { "<leader>f", group = "Telescope" },
    {
      "<leader>fw",
      "<cmd>lua require 'telescope-live-grep-args.shortcuts'.grep_visual_selection()<cr>",
      desc = "Find selected",
    },
    {
      "<leader>cn",
      ":<C-u>'<,'>PrtChatNew<cr>",
      desc = "New AI chat",
    },
  }

  local which_key = require "which-key"

  which_key.setup {
    plugins = {
      marks = false, -- shows a list of your marks on ' and `
      registers = false, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
      spelling = {
        enabled = true,
        suggestions = 20,
      }, -- use which-key for spelling hints
      -- the presets plugin, adds help for a bunch of default keybindings in Neovim
      -- No actual key bindings are created
      presets = {
        operators = false, -- adds help for operators like d, y, ...
        motions = false, -- adds help for motions
        text_objects = false, -- help for text objects triggered after entering an operator
        windows = false, -- default bindings on <c-w>
        nav = false, -- misc bindings to work with windows
        z = false, -- bindings for folds, spelling and others prefixed with z
        g = false, -- bindings for prefixed with g
      },
    },
    layout = {
      height = { min = 4, max = 25 }, -- min and max height of the columns
      width = { min = 20, max = 50 }, -- min and max width of the columns
      spacing = 3, -- spacing between columns
      align = "left", -- align columns left, center or right
    },
    show_help = true, -- show help message on the command line when the popup is visible
    show_keys = true, -- show the currently pressed key and its label as a message in the command line
    -- disable the WhichKey popup for certain buf types and file types.
    -- Disabled by default for Telescope
    disable = {
      buftypes = {},
      filetypes = { "TelescopePrompt" },
    },
  }

  which_key.add(mappings)
  which_key.add(vmappings)
end

return M
