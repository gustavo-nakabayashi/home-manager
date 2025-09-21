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

  # Enable Nix daemon
  services.nix-daemon.enable = true;

  # Nix configuration
  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      interval = {Weekday = 7;};
      options = "--delete-older-than 7d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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
      AppleInterfaceStyle = "Dark";
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
    (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono"];})
  ];

  # Homebrew integration (for GUI apps that aren't in nixpkgs)
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    brews = [
      "mas"
    ];

    casks = [
      "raycast"
      "karabiner-elements"
      "ghostty"
      "claude"
      "firefox"
      "visual-studio-code"
      "figma"
      "spotify"
      "discord"
      "cleanmymac"
      "1password"
    ];

    masApps = {
      "Xcode" = 497799835;
    };
  };

  # System activation scripts
  system.activationScripts.postUserActivation.text = ''
    # Following line should allow us to avoid a logout/login cycle
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  # System version
  system.stateVersion = 5;

  # User configuration
  users.users.gustavo = {
    name = "gustavo";
    home = "/Users/gustavo";
  };
}