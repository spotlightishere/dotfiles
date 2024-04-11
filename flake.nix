{
  description = "Spotlight's dotfiles";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Allows for easy enumeration of available Darwin and Linux systems.
    all-systems.url = "github:nix-systems/default";
    darwin-systems.url = "github:nix-systems/default-darwin";
    linux-systems.url = "github:nix-systems/default-linux";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, linux-systems, darwin-systems, all-systems, ... }:
    let
      # TODO(spotlightishere): Is there a better way to approach this that doesn't
      # involve importing so many separate flakes?
      #
      # (We could manually merge Darwin and Linux themselves, but this is primarily for readability.)
      allSystems = nixpkgs.lib.genAttrs (import all-systems);
      darwinSystems = nixpkgs.lib.genAttrs (import darwin-systems);
      linuxSystems = nixpkgs.lib.genAttrs (import linux-systems);

      homeManager = { system, specialArgs ? { } }:
        home-manager.lib.homeManagerConfiguration {
          modules = [
            ./home/home.nix
          ];
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = specialArgs;
        };
    in
    {
      # There's a few things going on here that are all merged in the end.
      # We start with system-specific packages, providing home-manager.
      packages =
        ##########################
        # Linux-specific options #
        ##########################
        linuxSystems
          (system: {
            homeConfigurations = {
              # First, we currently assume that Linux devices
              # only require dotfiles and utilize the username `spotlight`.
              #
              # For now, this is effectively true, sans a few specific configurations :)
              spotlight = homeManager {
                system = system;
                specialArgs = {
                  desktop = false;
                  gpg = false;
                };
              };

              # For a special case: with the Steam Deck, we have to assume the user
              # is named `deck` due to its immutable system image.
              deck = homeManager {
                system = system;
                specialArgs = {
                  gpg = true;
                  username = "deck";
                };
              };
            };
          })

        //

        ###########################
        # Darwin-specific options #
        ###########################
        darwinSystems (system: {
          # We use the username `spot` under Darwin.
          # We also assume that desktop applications should be made available, alongside GPG.
          homeConfigurations.spot = homeManager {
            system = system;
            specialArgs = {
              desktop = true;
              gpg = true;
            };
          };
        });

      # We provide a NixOS module for easy usage within other system flakes.
      # (Again, we assume a default name of `spotlight` under Linux.)
      nixosModules.default = {
        imports = [
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.spotlight = import ./home/home.nix;
              extraSpecialArgs = { desktop = false; gpg = false; };
            };
          }
        ];
      };

      # Lastly, ensure a formatter is available for all systems.
      formatter = allSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
