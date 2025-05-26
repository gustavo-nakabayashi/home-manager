require "autocmds"
require "keymaps"
require "launch"
require "options"
-- spec "user.plugins.alpha"
-- spec "user.plugins.bufdelete"
-- spec "user.plugins.bufferline"
-- spec "user.plugins.copilot"
-- spec "user.plugins.lsp-timeout"
spec "user.plugins.matchup"


spec "user.plugins.lualine"
-- spec "user.plugins.dressing"
spec "user.plugins.ufo"
spec "user.plugins.indentline"
--- SAFE PLUGINS

-- Aparently none of these are the leak
---- UI
spec "user.plugins.breadcrumbs"
-- spec "user.plugins.colorizer"
-- spec "user.plugins.navic"
-- spec "user.plugins.zen-mode"
spec "user.plugins.devicons"
spec "user.plugins.whichkey"
spec "user.plugins.no-neck"
-- spec "user.plugins.noice"

spec "user.plugins.autoread"

---- Treesitter
spec "user.plugins.illuminate"
spec "user.plugins.treesitter-context"
spec "user.plugins.treesitter"


-- --- UNTESTED PLUGINS
-- ---- LSP
-- -- spec "user.plugins.neorg"
spec "user.plugins.cmp"
-- spec "user.plugins.lspconfig"
spec "user.plugins.mason"
spec "user.plugins.null-ls"
-- spec "user.plugins.typescript-tools"
spec "user.plugins.trouble"


-- ---- Colorschemes
-- -- spec "user.plugins.colorscheme-base16"
-- -- spec "user.plugins.colorscheme-catppuccin"
-- -- spec "user.plugins.colorscheme-kanagawa"
-- -- spec "user.plugins.colorscheme-vim-colors"
-- -- spec "user.plugins.colorscheme-vivid"
spec "user.plugins.colorscheme-gruvbox"
-- -- spec "user.plugins.colorscheme-nightfox"
-- -- spec "user.plugins.colorscheme-solarized"
spec "user.plugins.colorscheme-tokyonight"

-- -- Git
-- -- spec "user.plugins.diffview"
-- -- spec "user.plugins.neogit"
spec "user.plugins.gitblame"
spec "user.plugins.gitsigns"
spec "user.plugins.lazygit"

-- ---- Files/navigation
-- -- spec "user.plugins.neotree"
-- spec "user.plugins.harpoon"
spec "user.plugins.nvimtree"
spec "user.plugins.telescope"
spec "user.plugins.snipe"

-- ---- Utils
spec "user.plugins.auto-save"
-- -- spec "user.plugins.autopairs"
-- -- spec "user.plugins.quickfix-reflector"
spec "user.plugins.repeat"
spec "user.plugins.auto-dark-mode"
spec "user.plugins.emmet"
spec "user.plugins.schemastore"
spec "user.plugins.undotree"
spec "user.plugins.visual-star-search"

-- ---- Motions or actions, textobjects/ vim enhancing features
spec "user.plugins.targets"
spec "user.plugins.comment"
spec "user.plugins.textobj-user"
spec "user.plugins.textobj-user-entire"
spec "user.plugins.nvim-surround"

spec "user.plugins.parrot"
spec "user.plugins.outline"
spec "user.plugins.oil-nvim"


require "user.lazy"
