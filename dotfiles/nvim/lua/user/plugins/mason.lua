local M = {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "nvim-lua/plenary.nvim",
  },
}

local servers = {
    "bashls",
    "clangd",
    "cssls",
    "eslint",
    "gopls",
    "html",
    "jsonls",
    "lua_ls",
    "marksman",
    "terraformls",
    "vtsls",
    "yamlls",
    -- "astro",
    -- "elixirls",
    -- "pyright",
    -- "tailwindcss",
    -- "tsserver",
}

-- Remove doubled react node defitions
local function filter(arr, fn)
  if type(arr) ~= "table" then
    return arr
  end

  local filtered = {}
  for k, v in pairs(arr) do
    if fn(v, k, arr) then
      table.insert(filtered, v)
    end
  end

  return filtered
end

local function filterReactDTS(value)
    return string.match(value.filename, 'react/index.d.ts') == nil end

local function on_list(options)
    -- [https://github.com/typescript-language-server/typescript-language-server/issues/216](https://github.com/typescript-language-server/typescript-language-server/issues/216)
    local items = options.items
    if #items > 1 then 
        items = filter(items, filterReactDTS)
    end

    vim.fn.setqflist({}, ' ', { title = options.title, items = items, context = options.context })
    vim.api.nvim_command('cfirst')
end

local function lsp_keymaps(bufnr)
  local opts = { noremap = true, silent = true }
  local keymap = vim.api.nvim_buf_set_keymap
  keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  -- keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition{on_list=on_list} end, opts)
  keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  keymap(bufnr, "n", "gI", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  keymap(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
end

M.on_init = function(client, initialization_result)
  if client.server_capabilities then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.semanticTokensProvider = nil  -- turn off semantic tokens
  end
end

M.on_attach = function(client, bufnr)
  lsp_keymaps(bufnr)
end

function M.common_capabilities()
  -- local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  -- if status_ok then
  --   return cmp_nvim_lsp.default_capabilities()
  -- end

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  }

  return capabilities
end


function M.config()
  require("mason").setup {
    ui = {
      border = "rounded",
    },
  }
  require("mason-lspconfig").setup {
    ensure_installed = servers,
  }

  require("mason-lspconfig").setup_handlers {
      -- The first entry (without a key) will be the default handler
      -- and will be called for each installed server that doesn't have
      -- a dedicated handler.

      function (server) -- default handler (optional)
          local opts = {
            on_attach = M.on_attach,
            on_init = M.on_init,
            capabilities = M.common_capabilities(),
          }

          if server == "gopls" then
            opts.settings = {
              gopls = {
                completeUnimported = true,
              }
            }
          end

          if server == "eslint" then
            opts.settings = {
              workingDirectories = { mode = "auto" },
            }
          end

          local require_ok, settings = pcall(require, "user.lspsettings." .. server)
          if require_ok then
            opts = vim.tbl_deep_extend("force", settings, opts)
          end

          if server == "lua_ls" then
            require("neodev").setup {}
          end

          require("lspconfig")[server].setup(opts)
      end,
  }
end

return M
