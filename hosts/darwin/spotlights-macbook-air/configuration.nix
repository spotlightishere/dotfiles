{ lib, pkgs, system, ... }: {
  imports = [
    ../shared/common.nix
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  environment.systemPackages = with pkgs; [
    google-cloud-sdk
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
}
