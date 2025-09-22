{
  config,
  pkgs,
  pkgs-unstable,
  mcp-nixos,
  lib,
  ...
}: {
  # Import base configuration
  imports = [ ./darwin.nix ];

  # Override primary user for gaming
  system.primaryUser = "gaming";

  # Gaming-specific system preferences
  system.defaults = {
    # Inherit most settings from base config but override specific ones
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
  };

  # Gaming-specific keyboard mapping
  system.keyboard = {
    enableKeyMapping = true;
    # Don't remap caps lock for gaming
    remapCapsLockToEscape = false;
    # Swap Cmd and Option to prevent accidental Cmd+Q
    swapLeftCommandAndLeftOption = true;
    swapRightCommandAndRightOption = true;
  };

  # User configuration
  users.users.gaming = {
    name = "gaming";
    home = "/Users/gaming";
  };
}