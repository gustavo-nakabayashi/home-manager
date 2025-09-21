{
  config,
  pkgs,
  pkgs-unstable,
  mcp-nixos,
  lib,
  ...
}: {
  # System packages (available system-wide)
  environment.systemPackages = with pkgs; [
    # Build tools and system utilities
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

    # Core development tools
    gh
    git

    # System monitoring
    btop
  ];

  # System-wide environment variables
  environment.variables = {
    EDITOR = "nvim";
    JAVA_HOME = "${pkgs.jdk21}";
  };

  # Nix configuration - disabled because using Determinate Nix
  nix.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set primary user for system preferences
  system.primaryUser = "gustavo";

  # macOS system preferences
  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.2;
      orientation = "bottom";
      show-recents = false;
      tilesize = 48;
      minimize-to-application = true;
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXDefaultSearchScope = "SCcf";
      FXPreferredViewStyle = "clmv";
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = null;
      AppleKeyboardUIMode = 3;
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      _HIHideMenuBar = false;
    };

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };

    screencapture = {
      location = "~/Desktop/Screenshots";
      type = "png";
    };
  };

  # System keyboard shortcuts and input
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  # Homebrew integration (for GUI apps that aren't in nixpkgs)
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    taps = [
      "koekeishiya/formulae"
    ];

    brews = [
      "mas"
      "skhd"
      "yabai"
    ];

    casks = [
      "alt-tab"
      "aws-vpn-client"
      "bartender"
      "claude"
      "cursor"
      "dbeaver-community"
      "discord"
      "figma"
      "firefox"
      "ghostty"
      "google-chrome"
      "intellij-idea-ce"
      "karabiner-elements"
      "microsoft-teams"
      "mongodb-compass"
      "notion"
      "obsidian"
      "orbstack"
      "perimeter81"
      "postman"
      "qbittorrent"
      "racket"
      "rar"
      "raycast"
      "shottr"
      "slack"
      "spotify"
      "stats"
      "sublime-text"
      "visual-studio-code"
      "1password"
    ];

    masApps = {
      "Xcode" = 497799835;
    };
  };


  # System version
  system.stateVersion = 5;

  # User configuration
  users.users.gustavo = {
    name = "gustavo";
    home = "/Users/gustavo";
  };
}
