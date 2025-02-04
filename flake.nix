{
  description = "Spotlight's dotfiles";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    apple-silicon-support = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix-darwin, vscode-server, ... }:
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
          pkgs = nixpkgs.legacyPackages.${system}.extend (self.overlays.default);
          extraSpecialArgs = specialArgs;
        };
    in
    {
      # First, we provide a generalized package overlay, providing several packages
      # for e.g. nix-darwin, NixOS, and home-manager usage.
      # ./pkgs/default.nix's singular argument, `pkgs`, is provided by our `final`.
      overlays.default = (final: prev: import ./pkgs/default.nix {
        pkgs = final;
      });

      # Next, we provide Linux-specific home-manager configurations,
      # and expose our default packages to the world.
      packages =
        let
          ##########################
          # Linux-specific options #
          ##########################
          linuxConfiguration = linuxSystems (system: {
            homeConfigurations = {
              # We currently assume that Linux devices only require
              # dotfiles and utilize the username `spotlight`.
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
          });

          # For all platforms, export our packages for CI to build.
          exportedPackages = allSystems (system: import ./pkgs/default.nix {
            pkgs = nixpkgs.legacyPackages.${system};
          });

          # We must use recursiveUpdate in order to go deeper beyond one level.
          # For example, `linuxConfiguration` provides `packages.x86_64-linux.homeConfiguration`
          # and `exportedPackages` provides `packages.x86_64-linux.<package name>`.
          #
          # With the normal `//` syntax, `packages.x86_64-linux` is not recursively merged,
          # and either packages or the home-manager configuration end up being replaced.
          # This is not ideal :(
          recursiveUpdate = nixpkgs.lib.recursiveUpdate;
        in
        recursiveUpdate linuxConfiguration exportedPackages;

      # We provide a NixOS module for easy usage within other system flakes.
      # (Again, we assume a default name of `spotlight` under Linux.)
      # TODO(spotlightishere): Have this module accept arguments that we can pass on
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

      # We define a NixOS configuration for a PC workstation.
      nixosConfigurations.cyclone = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/linux/cyclone/configuration.nix

          vscode-server.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [ self.overlays.default ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.spotlight = import ./home/home.nix;
              extraSpecialArgs = { desktop = true; gpg = true; };
            };
          }
        ];
      };

      nixosConfigurations = {
        "spotlights-macbook-air" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";

          modules = [
            # Asahi-specific tweaks
            inputs.apple-silicon-support.nixosModules.default
            ./hosts/linux/spotlights-macbook-air/configuration.nix

            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [ self.overlays.default ];
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.spotlight = import ./home/home.nix;
                extraSpecialArgs = { desktop = true; gpg = true; };
              };
            }
          ];
        };
      };

      # We define a NixOS configuration for a scratch VM.
      nixosConfigurations.flareon = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/linux/flareon/configuration.nix

          vscode-server.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [ self.overlays.default ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.spotlight = import ./home/home.nix;
              extraSpecialArgs = { desktop = false; gpg = false; };
            };
          }
        ];
      };

      # Raspberry Pi 4B
      nixosConfigurations.cornflower = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/linux/cornflower/configuration.nix

          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [ self.overlays.default ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.spotlight = import ./home/home.nix;
              extraSpecialArgs = { desktop = false; gpg = false; };
            };
          }
        ];
      };

      # We define a default Darwin configuration via nix-darwin.
      darwinConfigurations."spotlights-macbook-air" = nix-darwin.lib.darwinSystem {
        modules = [
          # System-wide configuration
          ./hosts/darwin/spotlights-macbook-air/configuration.nix
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

      darwinConfigurations."sequoia" = nix-darwin.lib.darwinSystem {
        modules = [
          # System-wide configuration
          ./hosts/darwin/sequoia/configuration.nix
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
