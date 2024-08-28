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
    JDK_LOCATION="$(find "${pkgs.jdk}" -name "*.jdk" | head -n1)"

    # Symlink!
    ln -sf "$JDK_LOCATION" "/Library/Java/JavaVirtualMachines/zulu-latest.jdk"

    ##########
    # JDK 17 #
    ##########
    # We'd also like JDK 17 available, for legacy purposes.
    # (The author of this is as disappointed in this as the reader should be.)
    rm -f /Library/Java/JavaVirtualMachines/zulu-17.jdk
    ln -sf "${pkgs.jdk17}/zulu-17.jdk" "/Library/Java/JavaVirtualMachines/zulu-17.jdk"
  '';

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix = {
    # Keep the latest version of Nix.
    package = pkgs.nix;
    # Necessary for using flakes on this system.
    settings.experimental-features = "nix-command flakes";
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  nixpkgs = {
    hostPlatform = lib.mkDefault "aarch64-darwin";

    # Regretfully, we use some non-free packages.
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      # Visual Studio Code
      "vscode"
    ];
  };

  # Our singular user!
  users.users.spot = {
    description = "Spotlight Deveaux";
    home = "/Users/spot";
    shell = pkgs.zsh;
  };
}
