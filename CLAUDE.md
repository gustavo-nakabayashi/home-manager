# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a nix-darwin and Home Manager configuration repository for managing a macOS development environment. The configuration is declarative and uses Nix flakes to ensure reproducibility. The repository manages both system-wide (nix-darwin) and user-specific (Home Manager) configurations, along with Homebrew integration for GUI applications.

## Architecture

### Core Files

- **flake.nix**: Entry point that defines all inputs (nixpkgs, nix-darwin, home-manager, etc.) and outputs (darwinConfigurations). Configures the system "Gustavos-MacBook-Pro" as an aarch64-darwin machine.
- **darwin.nix**: System-level configuration including system packages, macOS defaults, fonts, and Homebrew management. Uses nix-homebrew for declarative Homebrew tap management.
- **home.nix**: User-level configuration for user "gustavo", including development tools, language servers, formatters, shell configuration, and dotfile symlinks.

### Key Configuration Patterns

**Dual Channel Strategy**: Uses both stable (nixpkgs-25.05-darwin) and unstable (nixpkgs-unstable) channels. Unstable packages are available via `pkgs-unstable` specialArgs (e.g., neovim, claude-code, aerospace).

**Symlink Management**: home.nix uses `mkOutOfStoreSymlink` to symlink dotfiles from `~/.config/home-manager/home/` to their target locations. This keeps dotfiles in the repository while allowing in-place editing. Two patterns:
1. Directories symlinked recursively (nvim, aerospace, fd, ghostty, karabiner, ranger, tmuxinator)
2. Individual files with custom mappings (.p10k.zsh, .gitignore, karabiner.edn, claude-settings.json, .tmux.conf)

**Script Integration**: Custom shell scripts (tmux-sessionizer, tmux-pin-current, gwa) are packaged as binaries using `writeShellScriptBin` and included in home.packages.

**Git Conditional Configs**: Git configuration uses conditional includes to automatically set different email addresses for work directories (~/Programs/video-peel/ and ~/Programs/bridge/).

### Important Details

- **Determinate Nix**: Uses Determinate Nix installer, so `nix.enable = false` in darwin.nix
- **Homebrew Integration**: nix-homebrew manages Homebrew with immutable taps (`mutableTaps = false`), meaning taps cannot be added imperatively
- **Touch ID for sudo**: Enabled via `security.pam.services.sudo_local.touchIdAuth = true`

## Essential Commands

### System Management

```bash
# Apply system and home-manager changes
sudo darwin-rebuild switch --flake ~/.config/home-manager

# Apply only home-manager changes (user-level)
home-manager switch

# Update flake.lock inputs
nix flake update
```

### Development Workflow

When modifying the configuration:
1. Edit the relevant .nix file (darwin.nix for system, home.nix for user)
2. Test changes: `sudo darwin-rebuild switch --flake ~/.config/home-manager`
3. If issues occur, previous generations can be rolled back

### Shell Aliases

Defined in home.nix programs.zsh.shellAliases:
- `update`: Rebuild and switch the system configuration
- `update-home`: Apply home-manager changes only
- `lg`: lazygit
- `rn`: ranger
- `vi`: nvim
- `tx`: tmuxinator

## Development Environment

### Language Support

The configuration includes comprehensive language tooling:
- **Node.js**: nodejs, pnpm, vtsls (language server)
- **Go**: go, gopls, gofumpt, goimports-reviser
- **Java**: jdk21 (set as JAVA_HOME)
- **Lua**: lua, lua-language-server, stylua
- **Clojure**: clojure, babashka, clj-kondo, leiningen, clojure-lsp, cljfmt
- **PHP**: php
- **Nix**: nil, nixd, alejandra

### Editors and Tools

Primary editor: neovim (unstable) with configuration located at `home/.config/nvim/`. The neovim config uses Lazy.vim as the plugin manager and includes comprehensive language server and formatter support. Also includes Cursor, VSCode, IntelliJ IDEA CE, and Sublime Text via Homebrew.

Terminal: Ghostty (configuration at `home/.config/ghostty/`) with tmux and tmuxinator for session management.

## Adding Neovim Plugins

The Neovim configuration uses Lazy.vim for plugin management. To add a new plugin:

1. **Create a plugin file**: Create a new file in `home/.config/nvim/lua/user/plugins/<plugin-name>.lua` with the plugin configuration:
   ```lua
   local M = {
     "author/plugin-name",
     dependencies = { "dependency/plugin" }, -- optional
     event = "VeryLazy", -- or other lazy-loading event
   }

   function M.config()
     require("plugin-name").setup({
       -- configuration options
     })

     -- Keymaps (optional)
     local keymap = vim.keymap.set
     keymap("n", "<leader>key", "<cmd>Command<cr>", { desc = "Description" })
   end

   return M
   ```

2. **Register the plugin**: Add the plugin to `home/.config/nvim/init.lua` by adding a spec line:
   ```lua
   spec "user.plugins.<plugin-name>"
   ```
   Place it in the appropriate section (UI, LSP, Utils, Testing, etc.) or create a new section if needed.

3. **Apply changes**: The plugin will be automatically loaded by Lazy.vim on next Neovim launch. No need to run `home-manager switch` unless system packages are changed.
