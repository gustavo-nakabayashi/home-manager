vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  callback = function()
    vim.cmd "set formatoptions-=cro"
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = {
    "netrw",
    "Jaq",
    "qf",
    "git",
    "help",
    "man",
    "lspinfo",
    "spectre_panel",
    "lir",
    "DressingSelect",
    "tsplayground",
    "",
  },
  callback = function()
    vim.cmd [[
      nnoremap <silent> <buffer> q :close<CR>
      set nobuflisted
    ]]
  end,
})

vim.api.nvim_create_autocmd({ "CmdWinEnter" }, {
  callback = function()
    vim.cmd "quit"
  end,
})

vim.api.nvim_create_autocmd({ "VimResized" }, {
  callback = function()
    vim.cmd "tabdo wincmd ="
  end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  pattern = { "*" },
  callback = function()
    vim.cmd "checktime"
  end,
})

vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  callback = function()
    vim.highlight.on_yank { higroup = "Visual", timeout = 40 }
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "gitcommit", "markdown", "NeogitCommitMessage" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(false, client.id, ev.buf, { autotrigger = true })
    end
  end,
})


-- vim.api.nvim_create_autocmd({ "ColorScheme" }, {
--   pattern = {"*"},
--   callback = function()
--     vim.cmd "highlight NonText guibg=none"
--     vim.cmd "highlight Normal guibg=none"
--     vim.cmd "highlight EndOfBuffer guibg=none"
--   end,
-- })

-- vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
--   pattern = { "*.liquid" },
--   callback = function()
--     vim.cmd "setlocal filetype=html"
--     vim.cmd "setlocal syntax=liquid"
--   end,
-- })


-- vim.api.nvim_create_autocmd("VimEnter", {
-- 	callback = function()
--     harpoon = require("harpoon")
--     harpoon:list():select(4)
--     harpoon:list():select(3)
--     harpoon:list():select(2)
--     harpoon:list():select(1)
-- 	end,
-- })
