{
  description = "Spotlight's dotfiles";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
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
      packages = {
        # We currently assume that all x86_64-linux devices only
        # require dotfiles. For now, this is mostly true :)
        x86_64-linux.homeConfigurations.spotlight = homeManager {
          system = "x86_64-linux";
        };

        # Similarly (as of writing), all aarch64 Linux devices are headless
        # and primarily managed by other distro package managers.
        # This should likely be dealt with in the future!
        aarch64-linux.homeConfigurations.spotlight = homeManager {
          system = "aarch64-linux";
        };

        # For all architecture variants of Darwin, we don't want only dotfiles.
        aarch64-darwin.homeConfigurations.spot = homeManager {
          system = "aarch64-darwin";
          specialArgs = {
            desktop = true;
            gpg = true;
          };
        };
        x86_64-darwin.homeConfigurations.spot = homeManager {
          system = "x86_64-darwin";
          specialArgs = {
            desktop = true;
            gpg = true;
          };
        };
      };

      formatter = {
        aarch64-darwin = nixpkgs.legacyPackages.x86_64-darwin.nixpkgs-fmt;
        x86_64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
        aarch64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
        x86_64-linux = nixpkgs.legacyPackages.aarch64-linux.nixpkgs-fmt;
      };
    };
}
