{
  description = "Spotlight's dotfiles";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Temporarily use https://github.com/tpwrules/nixos-apple-silicon/pull/303
    # as stable mesa now supports the Asahi ABI fully.
    apple-silicon-support = {
      url = "github:tpwrules/nixos-apple-silicon?ref=pull/303/head";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      # We'll target the systems we use the most.
      # This may be expanded in the future (e.g. x86_64-freebsd).
      allSystems = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];

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
      overlays.default = import ./pkgs/default.nix;

      # Next, we provide Linux-specific home-manager configurations,
      # and re-export several functions for Garnix to build.
      packages = {
        ###############################
        # Linux-specific home manager #
        ###############################
        x86_64-linux = {
          homeConfigurations = {
            # We currently assume that Linux devices only require
            # dotfiles and utilize the username `spotlight`.
            #
            # For now, this is effectively true, sans a few specific configurations :)
            spotlight = homeManager {
              system = "x86_64-linux";
            };

            # For a special case: with the Steam Deck, we have to assume the user
            # is named `deck` due to its immutable system image.
            deck = homeManager {
              system = "x86_64-linux";
              specialArgs = {
                gpg = true;
                username = "deck";
              };
            };
          };
        };

        # Re-export various packages that we use (e.g. Asahi, i686).
        # This allows them to be cached via Garnix if necessary, saving local build time.
        aarch64-linux = {
          linux-asahi-kernel = inputs.apple-silicon-support.packages.aarch64-linux.linux-asahi.kernel;
          m1n1 = inputs.apple-silicon-support.packages.aarch64-linux.m1n1;
        };
        i686-linux = {
          grub2 = inputs.nixpkgs.legacyPackages.i686-linux.grub2;
          grub2_efi = inputs.nixpkgs.legacyPackages.i686-linux.grub2_efi;
        };
      };

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

      darwinConfigurations."spotlights-mac-pro" = nix-darwin.lib.darwinSystem {
        modules = [
          # System-wide configuration
          ./hosts/darwin/spotlights-mac-pro/configuration.nix
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
