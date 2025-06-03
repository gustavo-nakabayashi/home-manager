{
  config,
  pkgs,
  ...
}: {
  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = with pkgs; [
    lazygit
    thefuck
    btop
    terraform
    tmux
    # mise

    neovim
    fd
    ripgrep
    ranger
    zsh-powerlevel10k
    ncdu
    tmuxinator
    xclip
    tmux-mem-cpu-load
    unzip
    awscli2
    jq
    sops

    # languages
    nodejs
    nodePackages.prettier
    eslint

    go
    gofumpt
    goimports-reviser

    lua51Packages.lua
    lua51Packages.luarocks
    stylua

    php

    zulu21

    tree-sitter
    nixd
    alejandra
    nil

    # builds
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

    (pkgs.writeShellScriptBin "tmux-sessionizer" ''
      if [[ $# -eq 1 ]]; then
          selected=$1
      else
          selected=$({ find ~/ ~/Programs/video-peel ~/.config ~/Programs ~/Programs/bridge ~/csprimer    -mindepth 1 -maxdepth 1 -type d; }| fzf)
      fi

      if [[ -z $selected ]]; then
          exit 0
      fi

      selected_name=$(basename "$selected" | tr . _)
      tmux_running=$(pgrep tmux)

      if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
          tmux new-session -s $selected_name -c $selected
          exit 0
      fi

      if ! tmux has-session -t=$selected_name 2> /dev/null; then
          tmux new-session -ds $selected_name -c $selected
      fi

      tmux switch-client -t $selected_name

    '')
  ];

  home.file = {
    ".p10k.zsh".source = ./home/.p10k.zsh;
    ".gitignore".source = ./home/.gitignore;
    "karabiner.edn".source = ./home/karabiner.edn;
    ".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/home/.tmux.conf";
    ".config/nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/home/.config/nvim/lazy-lock.json";
  };

  home.file.".config" = {
    source = ./home/.config;
    recursive = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
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
      # eval "$(~/.nix-profile/bin/mise activate zsh)"

      export FZF_DEFAULT_COMMAND="fd"
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

      export PATH="/Users/gustavo/.local/bin:$PATH"

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
        "thefuck"
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
      push.autoSetupRemote = true;
    };
  };
}
