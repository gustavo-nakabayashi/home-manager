{
  description = "Your dead simple Home Manager configuration";

  inputs.nixpkgs = {
    url = "github:nixos/nixpkgs/nixos-25.05";
  };

  inputs.nixpkgs-unstable = {
    url = "github:nixos/nixpkgs/nixos-unstable";
  };

  inputs.home-manager = {
    url = "github:nix-community/home-manager/release-25.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
  }: {
    homeConfigurations = {
      "gustavo" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };

        extraSpecialArgs = {
          pkgs-unstable = import nixpkgs-unstable {
            system = "aarch64-darwin";
            config.allowUnfree = true;
          };
        };

        modules = [
          ./home.nix
          {
            home = {
              username = "gustavo";
              homeDirectory = "/Users/gustavo";
            };
          }
        ];
      };
    };
  };
}
