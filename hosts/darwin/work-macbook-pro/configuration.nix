{ lib, pkgs, system, ... }: {
  imports = [
    ../shared/common.nix
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # Override the default user.
  users.users.joshua = {
    description = "Joshua Jones";
    home = "/Users/joshua";
    shell = pkgs.zsh;
  };
  system.primaryUser = lib.mkForce "joshua";

  # Unset `spot`.
  users.users.spot = { };

  environment.systemPackages = with pkgs; [
    # Useful utilities
    aarch64-esr-decoder
    lz4

    # adb, fastboot, etc
    android-tools
    corellium-cli
    frida-tools
    jadx
    mitmproxy
    picocom
    uefitool
    uv

    # Containers
    # We'll use Podman for Docker usage.
    podman
    # https://github.com/containers/podman/issues/27056
    krunkit
    # Kubernetes
    kind
    kubectl
    kubernetes-helm
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "claude-code"
  ];
}
