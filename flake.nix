{
  description = "Spotlight's dotfiles";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    apple-silicon-support = {
      url = "github:tpwrules/nixos-apple-silicon";
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
      # First, we provide a generalized package overlay,
      # providing several packages for e.g. nix-darwin and NixOS usage.
      #
      # This does not contain standalone packages.
      # ./pkgs/default.nix's singular argument, `pkgs`, is provided by our `final`.
      overlays.default = import ./pkgs/default.nix;

      # Next, we provide Linux-specific home-manager configurations,
      # and re-export several functions for Garnix to build.
      packages =
        let
          # First, let us export Home Manager configurations,
          # and various packages to accelerate e.g. Asahi usage.
          exportedPackages = {
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
              linux-asahi-kernel = inputs.apple-silicon-support.packages.aarch64-linux.linux-asahi;
              m1n1 = inputs.apple-silicon-support.packages.aarch64-linux.m1n1;

              # Helper to have Garnix rebuild GNOME dependencies using libimobiledevice.
              gnome-session = inputs.nixpkgs.legacyPackages.aarch64-linux.gnome-session;
            };
            i686-linux = {
              grub2 = inputs.nixpkgs.legacyPackages.i686-linux.grub2;
              grub2_efi = inputs.nixpkgs.legacyPackages.i686-linux.grub2_efi;
            };
            x86_64-linux = {
              # Similar to aarch64-linux, helper to rebuild GNOME dependencies.
              gnome-session = inputs.nixpkgs.legacyPackages.x86_64-linux.gnome-session;
            };
          };

          # We additionally have an overlay consisting of
          # standlone packages, and overriden packages.
          #
          # Export these for Garnix as well.
          overlayContents = allSystems (system:
            let
              # Append our custom overlay to the current system's packages.
              pkgs = nixpkgs.legacyPackages.${system};
              overlayPkgs = pkgs.extend (self.overlays.default);

              # TODO(spotlightishere): Find a way to automate
              # retrieving the packages within our overlay.
              packageList = [
                # Standalone packages
                "ipsw"
                "monaco-powerline"
                "telnet"
                "corellium-cli"
                "usbfluxd"

                # Overridden packages within overlay
                "libtatsu"
                "libimobiledevice"
                "libimobiledevice-glue"
                "usbmuxd"
                "libusbmuxd"
                "libirecovery"
                "libplist"
                "idevicerestore"
              ];
            in
            # This is equivalent to taking the set [ ipsw ]
              # and emitting the attribute set { ipsw = overlayPkgs.ipsw }.
            nixpkgs.lib.genAttrs packageList (package: overlayPkgs.${package})
          );

          # We must use recursiveUpdate in order to go deeper beyond one level.
          # For example, `linuxConfiguration` provides `packages.x86_64-linux.homeConfiguration`
          # and `exportedPackages` provides `packages.x86_64-linux.<package name>`.
          #
          # With the normal `//` syntax, `packages.x86_64-linux` is not recursively merged,
          # and either packages or the home-manager configuration end up being replaced.
          # This is not ideal :(
          recursiveUpdate = nixpkgs.lib.recursiveUpdate;
        in
        recursiveUpdate exportedPackages overlayContents;

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
