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
    pkgs-unstable.gh
    git
    nodejs  # Needed for MCP servers

    # System monitoring
    btop

    # Window management
    pkgs-unstable.aerospace

    # Backup script (for manual runs)
    (writeShellScriptBin "home-backup" ''
      #!/usr/bin/env bash
      set -euo pipefail

      MOUNT_POINT="/Volumes/guslab-data"
      SMB_SHARE="smb://192.168.68.75/guslab-data"
      BACKUP_DEST="$MOUNT_POINT/guslab/home-backup"
      SOURCE="$HOME/"

      # Mount SMB share if not already mounted
      if ! mount | grep -q "$MOUNT_POINT"; then
        echo "Mounting SMB share..."
        # Use osascript to mount via Finder (uses Keychain credentials)
        osascript -e "mount volume \"$SMB_SHARE\"" || {
          echo "Failed to mount SMB share"
          exit 1
        }
        # Wait for mount to complete
        sleep 2
      fi

      # Ensure backup destination exists
      mkdir -p "$BACKUP_DEST"

      # Run rsync with common exclusions
      echo "Starting backup at $(date)"
      ${rsync}/bin/rsync -a --delete --size-only --itemize-changes \
        --exclude='.Trash' \
        --exclude='Downloads' \
        --exclude='Library/Caches' \
        --exclude='Library/Logs' \
        --exclude='Library/pnpm' \
        --exclude='Library/**/*Cache*' \
        --exclude='Library/**/*cache*' \
        --exclude='Library/**/ServiceWorker' \
        --exclude='Library/**/OptGuideOnDeviceModel' \
        --exclude='Library/**/GoogleUpdater/crx_cache' \
        --exclude='Library/Containers' \
        --exclude='Library/Daemon Containers' \
        --exclude='Library/Group Containers' \
        --exclude='Library/Saved Application State' \
        --exclude='Library/HTTPStorages' \
        --exclude='.cache' \
        --exclude='node_modules' \
        --exclude='.npm' \
        --exclude='.pnpm-store' \
        --exclude='.n' \
        --exclude='n' \
        --exclude='.nx' \
        --exclude='.direnv' \
        --exclude='.m2' \
        --exclude='.orbstack' \
        --exclude='OrbStack' \
        --exclude='.docker' \
        --exclude='.yarn' \
        --exclude='.nodenv' \
        --exclude='.sonarlint' \
        --exclude='.vscode' \
        --exclude='.idea' \
        --exclude='.aider*' \
        --exclude='.imdone' \
        --exclude='**/build' \
        --exclude='**/dist' \
        --exclude='**/out' \
        --exclude='**/target' \
        --exclude='**/.git/objects' \
        --exclude='.local/share' \
        "$SOURCE" "$BACKUP_DEST"

      echo "Backup completed at $(date)"
    '')
  ];

  # System-wide environment variables
  environment.variables = {
    EDITOR = "nvim";
    JAVA_HOME = "${pkgs.jdk21}";
  };

  # Custom DNS resolver for local domains (forces AdGuard, skips Google DNS fallback)
  environment.etc."resolver/local.com" = {
    text = "nameserver 192.168.68.66";
  };

  # Set PATH for GUI applications launched by launchd
  # Includes both system packages and Home Manager user packages
  launchd.user.envVariables = {
    PATH = "${config.users.users.gustavo.home}/.nix-profile/bin:/etc/profiles/per-user/gustavo/bin:${config.environment.systemPath}";
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
      mru-spaces = false;
    };

    screencapture = {
      location = "~/Documents/Screenshots";
      type = "png";
    };

    universalaccess = {
      reduceMotion = true;
    };
  };

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

    brews = [
      "borders"
      "mas"
    ];

    casks = [
      "sunsama"
      "alt-tab"
      "aws-vpn-client"
      # bartender - managed manually (v5)
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
      "steam"
      "home-assistant"
      "zen"
      "linear-linear"
    ];

    masApps = {
      # Xcode removed - latest version requires macOS 15.6+
      # Manage Xcode manually to stay on a compatible version
    };
  };

  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Periodic home backup
  launchd.user.agents.home-backup = {
    serviceConfig = {
      ProgramArguments = [
        "/run/current-system/sw/bin/home-backup"
      ];
      StartCalendarInterval = [
        {
          Hour = 2;
          Minute = 0;
        }
      ];
      StandardOutPath = "/Users/gustavo/Library/Logs/home-backup.log";
      StandardErrorPath = "/Users/gustavo/Library/Logs/home-backup.log";
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
