{ lib, pkgs, system, ... }: {
  environment = {
    # We'll use Vim globally.
    systemPackages = [
      pkgs.vim
    ];
    variables.EDITOR = "${pkgs.vim}/bin/vim";
  };

  # Per https://github.com/LnL7/nix-darwin/issues/663,
  # nix-darwin only supports a few specific named activation scripts.
  # We'll leverage `extraActivation` to symlink our JDKs.
  system.activationScripts.extraActivation.text = ''
    ##############
    # Latest JDK #
    ##############
    # Regardless of version, we'd like the latest JDK available.

    # Remove the symlink if it doesn't already exist.
    rm -f /Library/Java/JavaVirtualMachines/zulu-latest.jdk

    # We should only have a single JDK present within our package,
    # but let's limit `find` regardless.
    JDK_LOCATION="$(find "${pkgs.jdk24}" -name "*.jdk" | head -n1)"

    # Symlink!
    ln -sf "$JDK_LOCATION" "/Library/Java/JavaVirtualMachines/zulu-latest.jdk"

    ##########
    # JDK 21 #
    ##########
    # We'd also like the latest LTS version of the JDK available.
    rm -f /Library/Java/JavaVirtualMachines/zulu-21.jdk
    ln -sf "${pkgs.jdk21}/zulu-21.jdk" "/Library/Java/JavaVirtualMachines/zulu-21.jdk"
  '';

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
