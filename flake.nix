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
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix-darwin, ... }:
    let
      # TODO(spotlightishere): Is there a better way to approach this that doesn't
      # involve importing so many separate flakes?
      #
      # (We could manually merge Darwin and Linux themselves, but this is primarily for readability.)
      allSystems = nixpkgs.lib.genAttrs (import inputs.all-systems);
      darwinSystems = nixpkgs.lib.genAttrs (import inputs.darwin-systems);
      linuxSystems = nixpkgs.lib.genAttrs (import inputs.linux-systems);

      homeManager = { system, specialArgs ? { } }:
        home-manager.lib.homeManagerConfiguration {
          modules = [
            ./home/home.nix
          ];
          pkgs = nixpkgs.legacyPackages.${system}.extend (import ./pkgs/default.nix);
          extraSpecialArgs = specialArgs;
        };
    in
    {
      # There's a few things going on here that are all merged in the end.
      # We start with a generalized package overlay, providing several packages
      # for e.g. nix-darwin, NixOS, and home-manager usage.
      overlays.default = (import ./pkgs/default.nix);

      # Secondly, we create system-specific home-manager configurations.
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
        })

        //

        ####################
        # Generic packages #
        ####################
        # We'll export some of our overlay's packages for CI to build.
        allSystems (system: {
          packages = {
            swiftformat = import ./pkgs/swiftformat.nix;
            monaco-powerline = import ./monaco-powerline/default.nix;
          };
        });

      # We provide a NixOS module for easy usage within other system flakes.
      # (Again, we assume a default name of `spotlight` under Linux.)
      nixosModules.default = {
        imports = [
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [ self.overlays.default ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.spotlight = import ./home/home.nix;
            };
          }
        ];
      };

      # We define a default Darwin configuration via nix-darwin.
      darwinConfigurations."spotlights-macbook-air" = nix-darwin.lib.darwinSystem {
        modules = [
          # System-wide configuration
          ./darwin/darwin.nix
          # Our provided home-manager configuration
          home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [ self.overlays.default ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.spot = import ./home/home.nix;
              extraSpecialArgs = { desktop = true; gpg = true; };
            };
          }
        ];
      };

      # Lastly, ensure a formatter is available for all systems.
      formatter = allSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
