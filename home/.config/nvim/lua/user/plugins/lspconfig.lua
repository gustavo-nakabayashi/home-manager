local M = {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    {
      {
        "folke/lazydev.nvim",
        ft = "lua",
        cmd = "LazyDev",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
      "yioneko/nvim-vtsls",
    },
  },
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
  return string.match(value.filename, "react/index.d.ts") == nil
end

local function on_list(options)
  -- [https://github.com/typescript-language-server/typescript-language-server/issues/216](https://github.com/typescript-language-server/typescript-language-server/issues/216)
  local items = options.items
  if #items > 1 then
    items = filter(items, filterReactDTS)
  end

  vim.fn.setqflist({}, " ", { title = options.title, items = items, context = options.context })
  vim.api.nvim_command "cfirst"
end

local function lsp_keymaps(bufnr)
  local opts = { noremap = true, silent = true }
  local keymap = vim.api.nvim_buf_set_keymap
  keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  -- keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  vim.keymap.set("n", "gd", function()
    vim.lsp.buf.definition { on_list = on_list }
  end, opts)
  keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  keymap(bufnr, "n", "gI", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  keymap(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
end

M.on_init = function(client, initialization_result)
  if client.server_capabilities then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.semanticTokensProvider = nil -- turn off semantic tokens
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end
    local bufnr = ev.buf
    local server_name = client.name

    lsp_keymaps(bufnr, server_name)
  end,
})

function M.common_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

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
  local lspconfig = require "lspconfig"
  require("lspconfig.ui.windows").default_options.border = "rounded"

  vim.lsp.config("*", {
    on_init = M.on_init,
    capabilities = M.common_capabilities(),
  })

  vim.lsp.config("gopls", {
    settings = {
      gopls = {
        completeUnimported = true,
      },
    },
  })

  vim.lsp.config("eslint", {
    root_dir = function(bufnr, on_dir)
      local util = require "lspconfig.util"
      local root_file_patterns = {
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.cjs",
        ".eslintrc.yaml",
        ".eslintrc.yml",
        ".eslintrc.json",
        "eslint.config.js",
        "eslint.config.mjs",
        "eslint.config.cjs",
        "eslint.config.ts",
        "eslint.config.mts",
        "eslint.config.cts",
      }

      local fname = vim.api.nvim_buf_get_name(bufnr)
      root_file_patterns = util.insert_package_json(root_file_patterns, "eslintConfig", fname)
      on_dir(vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1]))
    end,
  })

  vim.lsp.config("vtsls", {
    -- explicitly add default filetypes, so that we can extend
    -- them in related extras
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    },
    settings = {
      complete_function_calls = true,
      vtsls = {
        enableMoveToFileCodeAction = true,
        autoUseWorkspaceTsdk = true,
        experimental = {
          maxInlayHintLength = 30,
          completion = {
            enableServerSideFuzzyMatch = true,
          },
        },
      },
      typescript = {
        updateImportsOnFileMove = { enabled = "always" },
        suggest = {
          completeFunctionCalls = true,
        },
        inlayHints = {
          enumMemberValues = { enabled = true },
          functionLikeReturnTypes = { enabled = true },
          parameterNames = { enabled = "literals" },
          parameterTypes = { enabled = true },
          propertyDeclarationTypes = { enabled = true },
          variableTypes = { enabled = false },
        },
      },
    },
  })

  vim.lsp.enable "bashls"
  vim.lsp.config("clojure_lsp", {
    settings = {
      ["clojure-lsp"] = {
        hover = {
          hideFileLocation = false,
        },
      },
    },
  })
  vim.lsp.enable "clojure_lsp"
  vim.lsp.enable "cssls"
  vim.lsp.enable "eslint"
  vim.lsp.enable "gopls"
  vim.lsp.enable "html"
  vim.lsp.enable "jsonls"
  vim.lsp.enable "lua_ls"
  vim.lsp.enable "marksman"
  vim.lsp.enable "nil_ls"
  vim.lsp.enable "nixd"
  vim.lsp.enable "racket_langserver"
  vim.lsp.enable "terraformls"
  vim.lsp.enable "vtsls"
  vim.lsp.enable "yamlls"

  local icons = require "user.icons"
  local default_diagnostic_config = {
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
        [vim.diagnostic.severity.WARN] = icons.diagnostics.Warning,
        [vim.diagnostic.severity.INFO] = icons.diagnostics.Information,
        [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
      },
    },
    virtual_text = false,
    update_in_insert = false,
    underline = false,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(default_diagnostic_config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
end

return M
