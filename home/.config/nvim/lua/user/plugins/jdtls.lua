local M = {
  "mfussenegger/nvim-jdtls",
  ft = "java",
}

function M.config()
  local jdtls = require "jdtls"
  local lspconfig = require "user.plugins.lspconfig"

  -- Find the project root based on common Java project markers
  local root_markers = { "gradlew", "mvnw", ".git", "pom.xml", "build.gradle", "build.gradle.kts" }
  local root_dir = vim.fs.dirname(vim.fs.find(root_markers, { upward = true })[1])
    or vim.fn.getcwd()

  -- Workspace directory for jdtls data
  local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
  local workspace_dir = vim.fn.stdpath "data" .. "/jdtls-workspace/" .. project_name

  -- Determine the OS
  local os_config = "mac"
  if vim.fn.has "linux" == 1 then
    os_config = "linux"
  end

  -- Find jdtls installation from nix
  local jdtls_path = vim.fn.exepath "jdtls"
  local jdtls_install_dir = vim.fn.fnamemodify(jdtls_path, ":h:h")

  -- Build the command to start jdtls
  local cmd = {
    "jdtls",
    "-data", workspace_dir,
  }

  -- Extended capabilities for nvim-jdtls
  local extendedClientCapabilities = jdtls.extendedClientCapabilities
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

  local config = {
    cmd = cmd,
    root_dir = root_dir,
    on_init = lspconfig.on_init,
    capabilities = lspconfig.common_capabilities(),

    settings = {
      java = {
        eclipse = {
          downloadSources = true,
        },
        configuration = {
          updateBuildConfiguration = "interactive",
          -- Add runtimes if you have multiple JDKs
          -- runtimes = {
          --   { name = "JavaSE-21", path = vim.env.JAVA_HOME },
          -- },
        },
        maven = {
          downloadSources = true,
        },
        implementationsCodeLens = {
          enabled = true,
        },
        referencesCodeLens = {
          enabled = true,
        },
        references = {
          includeDecompiledSources = true,
        },
        signatureHelp = {
          enabled = true,
        },
        format = {
          enabled = false, -- Use google-java-format via null-ls instead
        },
        completion = {
          favoriteStaticMembers = {
            "org.junit.jupiter.api.Assertions.*",
            "org.junit.Assert.*",
            "org.mockito.Mockito.*",
            "org.mockito.ArgumentMatchers.*",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
          },
          importOrder = {
            "java",
            "javax",
            "com",
            "org",
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
        codeGeneration = {
          toString = {
            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
          },
          useBlocks = true,
        },
      },
    },

    init_options = {
      extendedClientCapabilities = extendedClientCapabilities,
    },
  }

  -- Start or attach to jdtls
  jdtls.start_or_attach(config)

  -- Set up keymaps specific to Java
  local opts = { buffer = true, silent = true }

  -- Organize imports
  vim.keymap.set("n", "<leader>jo", function()
    jdtls.organize_imports()
  end, vim.tbl_extend("force", opts, { desc = "Organize imports" }))

  -- Extract variable
  vim.keymap.set("n", "<leader>jv", function()
    jdtls.extract_variable()
  end, vim.tbl_extend("force", opts, { desc = "Extract variable" }))
  vim.keymap.set("v", "<leader>jv", function()
    jdtls.extract_variable(true)
  end, vim.tbl_extend("force", opts, { desc = "Extract variable" }))

  -- Extract constant
  vim.keymap.set("n", "<leader>jc", function()
    jdtls.extract_constant()
  end, vim.tbl_extend("force", opts, { desc = "Extract constant" }))
  vim.keymap.set("v", "<leader>jc", function()
    jdtls.extract_constant(true)
  end, vim.tbl_extend("force", opts, { desc = "Extract constant" }))

  -- Extract method (visual mode only)
  vim.keymap.set("v", "<leader>jm", function()
    jdtls.extract_method(true)
  end, vim.tbl_extend("force", opts, { desc = "Extract method" }))

  -- Test methods (requires java-debug and java-test)
  vim.keymap.set("n", "<leader>jt", function()
    jdtls.test_nearest_method()
  end, vim.tbl_extend("force", opts, { desc = "Test nearest method" }))

  vim.keymap.set("n", "<leader>jT", function()
    jdtls.test_class()
  end, vim.tbl_extend("force", opts, { desc = "Test class" }))
end

return M
