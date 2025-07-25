{ pkgs, ... }: {
  imports = [
    ./defaults.nix
    ./java.nix
  ];

  # We'd like to use Vim globally.
  environment = {
    systemPackages = [
      pkgs.vim
    ];
    variables.EDITOR = "${pkgs.vim}/bin/vim";

    # Ensure that the macOS-provided paths and man page paths are respected.
    # See also: https://github.com/nix-darwin/nix-darwin/issues/391
    etc."zprofile.local".source = ./zprofile.local;
  };

  # Similarly, we'd like to use zsh.
  programs.zsh.enable = true;

  # We make the assumption our user is named `spot`.
  users.users.spot = {
    description = "Spotlight Deveaux";
    home = "/Users/spot";
    shell = pkgs.zsh;
  };
  system.primaryUser = "spot";

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
}
