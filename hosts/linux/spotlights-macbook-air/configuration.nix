{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../shared.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = false;
  };

  # Asahi Linux support
  # Options such as `withRust` are no longer necessary.
  hardware.asahi.peripheralFirmwareDirectory = /boot/asahi;

  networking = {
    hostName = "spotlights-macbook-air";
    wireless.iwd = {
      enable = true;
      settings.General.EnableNetworkConfiguration = true;
    };

    # Necessary for WireGuard
    firewall.checkReversePath = false;
  };

  # As recommended in https://nixos.wiki/wiki/Libvirt#Setup
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };
  };

  # Docker
  users.users.spotlight.extraGroups = [ "docker" ];
  virtualisation.docker.enable = true;

  services = {
    # iOS tethering, etc
    usbmuxd.enable = true;

    tailscale.enable = true;

    syncthing.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # For usage with FEXRootFSFetcher
    erofs-utils
    fex
    legcord
    muvm
    vscode
    wireguard-tools
  ];

  # :(
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "vscode"
  ];

  system.stateVersion = "24.05";
}
