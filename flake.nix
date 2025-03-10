{
  description = "Your dead simple Home Manager configuration";

  inputs.nixpkgs = {
    # url = "github:nixos/nixpkgs/nixos-23.05";         ## Most stable, less downloads
    url = "github:nixos/nixpkgs/nixpkgs-unstable";  ## Bleeding edge packages
    # url = "github:nixos/nixpkgs/nixos-unstable";    ## Above, but with nixos tests
  };

  inputs.home-manager = {
    # url = "github:nix-community/home-manager/release-23.05";

    ## Track the master branch of Home Manager if you are not on a stable
    ## release
    url = "github:nix-community/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager }: {
    homeConfigurations = {
      "gustavo@devserver" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [
          ./home.nix
          {
            home = {
              username = "gustavo";
              homeDirectory = "/home/gustavo";
            };
          }
        ];
      };
      
      "gustavo@Gustavos-MacBook-Pro" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
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
      
      # Add an alias for the same configuration without hostname
      "gustavo" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
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
