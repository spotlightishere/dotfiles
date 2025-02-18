{ lib, pkgs, system, ... }: {
  environment = {
    # We'll use Vim globally.
    systemPackages = [
      pkgs.vim
    ];
    variables.EDITOR = "${pkgs.vim}/bin/vim";
  };

  # Auto upgrade the nix package.
  nix = {
    # Keep the latest version of Nix.
    package = pkgs.nix;
    settings = {
      # Necessary for using flakes on this system.
      experimental-features = "nix-command flakes";

      # Include Garnix
      substituters = [ "https://cache.garnix.io" ];
      trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
    };
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-darwin";

  # Our singular user!
  users.users.spot = {
    description = "Spotlight Deveaux";
    home = "/Users/spot";
    shell = pkgs.zsh;
  };
}
