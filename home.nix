{
  config,
  pkgs,
  pkgs-unstable,
  mcp-nixos,
  lib,
  ...
}: {
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # Organize packages by category
  home.packages = with pkgs;
    [
      # Core tools
      tmux
      tmuxinator
      tmux-mem-cpu-load
      gh
      # CLI utilities
      lazygit
      btop
      ranger
      ncdu
      fd
      ripgrep
      xclip
      unzip
      jq
      sops
      mysql80
      wget

      tree-sitter

      # AI assistants
      mcp-nixos
      uv

      # DevOps
      terraform
      awscli2

      # Programming languages
      nodejs
      go
      jdk21
      lua51Packages.lua
      lua51Packages.luarocks
      php
      clojure
      babashka

      # LSPs
      bash-language-server
      clojure-lsp
      gopls
      lua-language-server
      marksman
      nil
      nixd
      terraform-ls
      vscode-langservers-extracted
      vtsls
      yaml-language-server
      sonarlint-ls

      # Formatters
      alejandra
      stylua
      gofumpt
      goimports-reviser
      nodePackages.prettier

      # # Build dependencies
      bison
      flex
      fontforge
      makeWrapper
      pkg-config
      gnumake
      gcc
      libiconv
      autoconf
      automake
      libtool

      # Theme
      zsh-powerlevel10k

      # Custom scripts
      (pkgs.writeShellScriptBin "tmux-sessionizer" (builtins.readFile (builtins.path {
        path = ./home/scripts/tmux-sessionizer.sh;
        name = "tmux-sessionizer-sh";
      })))
      (pkgs.writeShellScriptBin "tmux-pin-current" (builtins.readFile (builtins.path {
        path = ./home/scripts/tmux-pin-current;
        name = "tmux-pin-current";
      })))
      (pkgs.writeShellScriptBin "gwa" (builtins.readFile (builtins.path {
        path = ./home/scripts/gwa;
        name = "gwa";
      })))
    ]
    ++ (with pkgs-unstable; [
      neovim
      claude-code
      # AI assistants (unstable)
    ]);

  home.file.".config" = {
    source = builtins.path {
      path = ./home/.config;
      name = "config";
    };
    recursive = true;
  };

  home.file = {
    ".p10k.zsh".source = builtins.path {
      path = ./home/.p10k.zsh;
      name = "p10k-zsh";
    };
    ".gitignore".source = builtins.path {
      path = ./home/.gitignore;
      name = "gitignore";
    };
    "karabiner.edn".source = builtins.path {
      path = ./home/karabiner.edn;
      name = "karabiner-edn";
    };
    ".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/home/.tmux.conf";
    ".config/nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/home/lazy-lock.json";
    ".local/bin/tmux-sessionizer".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/home/scripts/tmux-sessionizer.sh";
    ".claude/settings.json".source = builtins.path {
      path = ./home/claude-settings.json;
      name = "claude-settings-json";
    };
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    PATH = "$HOME/.local/bin:$PATH";
    JAVA_HOME = "${pkgs.jdk21}";
    SONAR_LINT_HOME = "${pkgs.sonarlint-ls}";
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "fd";
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initContent = ''
      if [ -f ~/.secret-env ]; then
        source ~/.secret-env
      fi

      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ~/.p10k.zsh

      export FZF_DEFAULT_COMMAND="fd"
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

      echo 'eval "$(direnv hook zsh)"'
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "npm"
        "history"
        "node"
        "rust"
        "deno"
        "aws"
        "gh"
        "git-auto-fetch"
      ];
    };

    shellAliases = {
      ll = "ls -l";
      update = "home-manager switch";
      lg = "lazygit";
      rn = "ranger";
      gc = "git clone";
      vi = "nvim";
      gcm = "git commit -m";
      tx = "tmuxinator";
      c = "code .";
      neorg = "cd ~/notes/ && nvim -c 'Neorg index'";
    };

    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";
  };

  programs.git = {
    enable = true;
    userName = "Gustavo Campos";
    userEmail = "gustavobcampos7@gmail.com";

    includes = [
      {
        condition = "gitdir:~/Programs/video-peel/";
        contents = {
          user = {
            email = "gustavo@videopeel.com";
            name = "Gustavo Campos";
          };
        };
      }
      {
        condition = "gitdir:~/Programs/bridge/";
        contents = {
          user = {
            email = "gcampos@bridgemarketplace.com";
            name = "Gustavo Campos";
          };
        };
      }
    ];

    extraConfig = {
      pull.ff = "only";
      init.defaultBranch = "main";

      filter.lfs = {
        process = "git-lfs filter-process";
        required = true;
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
      };

      core.excludesFile = "~/.gitignore";
      core.hooksPath = "~/.config/home-manager/home/scripts/git-hooks";
      push.autoSetupRemote = true;
    };
  };
}
