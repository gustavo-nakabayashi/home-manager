{
  description = "nix-darwin and Home Manager configuration";

  inputs.nixpkgs = {
    url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";
  };

  inputs.nixpkgs-unstable = {
    url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  inputs.nix-darwin = {
    url = "github:LnL7/nix-darwin/nix-darwin-25.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.home-manager = {
    url = "github:nix-community/home-manager/release-25.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.mcp-nixos = {
    url = "github:utensils/mcp-nixos";
  };

  inputs.nix-homebrew = {
    url = "github:zhaofengli/nix-homebrew";
  };

  inputs.homebrew-core = {
    url = "github:homebrew/homebrew-core";
    flake = false;
  };

  inputs.homebrew-cask = {
    url = "github:homebrew/homebrew-cask";
    flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nix-darwin,
    home-manager,
    mcp-nixos,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
  }: {
    darwinConfigurations = {
      "Gustavos-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";

        specialArgs = {
          pkgs-unstable = import nixpkgs-unstable {
            system = "aarch64-darwin";
            config.allowUnfree = true;
          };
          mcp-nixos = mcp-nixos.packages.aarch64-darwin.default;
        };

        modules = [
          ./darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.gustavo = import ./home.nix;
            home-manager.extraSpecialArgs = {
              pkgs-unstable = import nixpkgs-unstable {
                system = "aarch64-darwin";
                config.allowUnfree = true;
              };
              mcp-nixos = mcp-nixos.packages.aarch64-darwin.default;
            };
          }
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              # Install Homebrew under the default prefix
              enable = true;

              # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
              enableRosetta = true;

              # User owning the Homebrew prefix
              user = "gustavo";

              # Optional: Declarative tap management
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
              };

              # Optional: Enable fully-declarative tap management
              #
              # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
              mutableTaps = false;
            };
          }
          # Optional: Align homebrew taps config with nix-homebrew
          ({config, ...}: {
            homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
          })
        ];
      };
    };
  };
}
