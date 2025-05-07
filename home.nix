{ config, pkgs, ... }:

{
  home.stateVersion = "23.11"; # Please read the comment before changing.

    home.packages = with pkgs; [
      lazygit
      cargo
      mise
      thefuck
      btop
      mosh
      autossh
      terraform

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

# # It is sometimes useful to fine-tune packages, for example, by applying
# # overrides. You can do that directly here, just don't forget the
# # parentheses. Maybe you want to install Nerd Fonts with a limited number of
# # fonts?
# (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })


# # You can also create simple shell scripts directly inside your
# # configuration. For example, this adds a command 'my-hello' to your
# # environment:

(pkgs.writeShellScriptBin "tmux-sessionizer" ''
  if [[ $# -eq 1 ]]; then
      selected=$1
  else
      selected=$({ find ~/Programs/video-peel ~/.config ~/Programs ~/Programs/bridge ~/csprimer    -mindepth 1 -maxdepth 1 -type d; }| fzf)
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

(pkgs.writeShellScriptBin "remote-sync" ''
  # Sync the current directory

  rsync -vhra \
      "$(pwd)" \
      "gustavo@192.168.0.11:$(echo "''${PWD%/*}" | sed "s|$HOME|~|")" \
      --exclude "node_modules" \
      --exclude ".git" \
      --include="**.gitignore"  \
      --filter=":- .gitignore"


  # Exit with rsync's status code
  exit $?
'')

      ];

  home.file = {
  ".tmux.conf".source = dotfiles/.tmux.conf;
  ".p10k.zsh".source = dotfiles/.p10k.zsh;
  ".gitignore".source = dotfiles/.gitignore;
  ".config/nvim/lua".source = dotfiles/nvim/lua;
  ".config/nvim/init.lua".source =  dotfiles/nvim/init.lua;
  ".config/nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/dotfiles/nvim/lazy-lock.json";
  };

  # home.file."file.foo".source = config.lib.file.mkOutOfStoreSymlink ./path/to/file/to/link;
# Home Manager can also manage your environment variables through
# 'home.sessionVariables'. These will be explicitly sourced when using a
# shell provided by Home Manager. If you don't want to manage your shell
# through Home Manager then you have to manually source 'hm-session-vars.sh'
# located at either
#
#  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
#
# or
#
#  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
#
# or
#
#  /etc/profiles/per-user/gustavo/etc/profile.d/hm-session-vars.sh
#

  home.sessionVariables = {
    EDITOR = "nvim";
  };







# programs.fzf = {
#   enable = true;
#   keybindings = true;
#   };
  programs.fzf = {
    enable = true;
    defaultCommand = "fd";
  };



# Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
    if [ -f ~/.secret-env ]; then
      source ~/.secret-env
    fi

    source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    source ~/.p10k.zsh
    eval "$(~/.nix-profile/bin/mise activate zsh)"

    export FZF_DEFAULT_COMMAND="fd"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

    export PATH="/Users/gustavo/.local/bin:$PATH"


    function y() {
      local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
      yazi "$@" --cwd-file="$tmp"
      if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
      fi
      rm -f -- "$tmp"
    }
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
      lg="lazygit";
      rn="y";
      gc="git clone";
      vi="mise x node@lts -- nvim";
      gcm="git commit -m";
      sts="shopify theme serve";
      tx="tmuxinator";
      c="code .";
      neorg="cd ~/notes/ && nvim -c 'Neorg index'";
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


  programs.tmux = {
    enable = true;
    sensibleOnTop = false;


    extraConfig = ''
      # Either source another config file, you push as a managed home-manager file (see xdg.Configfile)
      source-file ~/.tmux.conf
      
      # our just specify your tmux config here, if you like embedding config in nix.
      # .....
    '';
  };





}

