{ pkgs, system, ... }: {
  environment = {
    # We'll use Vim globally.
    systemPackages = [
      pkgs.vim
    ];
    variables.EDITOR = "${pkgs.vim}/bin/vim";
  };

  system.activationScripts.extraActivation.text = '' 
    # Remove the symlink if it doesn't already exist.
    rm -f /Library/Java/JavaVirtualMachines/zulu-latest.jdk

    # We should only have a single JDK present within our package,
    # but let's limit `find` regardless.
    JDK_LOCATION="$(find "${pkgs.jdk}" -name "*.jdk" | head -n1)"

    # Symlink!
    ln -sf "$JDK_LOCATION" "/Library/Java/JavaVirtualMachines/zulu-latest.jdk"
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
    # TODO(spotlightishere): Make this configurable beyond a singular device.
    hostPlatform = "aarch64-darwin";

    # Custom packages.
    # TODO(spotlightishere): Why does this need to be specified in both home-manager and globally?
    overlays = [ (import ../pkgs/default.nix) ];
  };

  # Our singular user!
  users.users.spot = {
    description = "Spotlight Deveaux";
    home = "/Users/spot";
    shell = pkgs.zsh;
  };
}
