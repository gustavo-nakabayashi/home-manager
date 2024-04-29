require "autocmds"
require "keymaps"
require "launch"
require "options"

-- spec "user.plugins.alpha"
-- spec "user.plugins.bufdelete"
-- spec "user.plugins.bufferline"
-- spec "user.plugins.copilot"
-- spec "user.plugins.trouble"
-- spec "user.plugins.lsp-timeout"
-- spec "user.plugins.matchup"

---- LSP
spec "user.plugins.cmp"
spec "user.plugins.mason"
spec "user.plugins.lspconfig"
spec "user.plugins.null-ls"
spec "user.plugins.typescript-tools"
-- spec "user.plugins.neorg"

---- Treesitter
-- spec "user.plugins.illuminate"
spec "user.plugins.treesitter"
spec "user.plugins.treesitter-context"

---- Colorschemes
-- spec "user.plugins.colorscheme-base16"
-- spec "user.plugins.colorscheme-catppuccin"
spec "user.plugins.colorscheme-gruvbox"
-- spec "user.plugins.colorscheme-kanagawa"
-- spec "user.plugins.colorscheme-vivid"
spec "user.plugins.colorscheme-tokyonight"
-- spec "user.plugins.colorscheme-vim-colors"
spec "user.plugins.colorscheme-solarized"
spec "user.plugins.colorscheme-nightfox"

-- Git
spec "user.plugins.diffview"
spec "user.plugins.gitblame"
spec "user.plugins.gitsigns"
spec "user.plugins.neogit"

---- UI
-- spec "user.plugins.breadcrumbs"
-- spec "user.plugins.navic"
spec "user.plugins.indentline"
-- spec "user.plugins.colorizer"
spec "user.plugins.devicons"
spec "user.plugins.lualine"
spec "user.plugins.whichkey"
-- spec "user.plugins.zen-mode"
spec "user.plugins.dressing"

---- Files/navigation
spec "user.plugins.nvimtree"
-- spec "user.plugins.neotree"
spec "user.plugins.telescope"
spec "user.plugins.harpoon"

---- Utils
spec "user.plugins.auto-dark-mode"
-- spec "user.plugins.auto-save"
-- spec "user.plugins.autopairs"
spec "user.plugins.autoread"
spec "user.plugins.nvim-surround"
-- spec "user.plugins.repeat"
spec "user.plugins.schemastore"
spec "user.plugins.emmet"
spec "user.plugins.undotree"
spec "user.plugins.visual-star-search"
-- spec "user.plugins.quickfix-reflector"
spec "user.plugins.ufo"

---- Motions or actions, textobjects/ vim enhancing features
spec "user.plugins.comment"
spec "user.plugins.textobj-user"
spec "user.plugins.textobj-user-entire"
-- spec "user.plugins.targets"

require "user.lazy"
