# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

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

  # Allow GNOME to dynamically set the
  # time zone based on current location.
  #
  # https://www.reddit.com/r/NixOS/comments/1411gjs/comment/jo4wau3/
  time.timeZone = lib.mkForce null;

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

  nixpkgs.overlays = [
    (final: prev: {
      # We need SMBIOS generation enabled for libvirtd,
      # as it otherwise stumbles over executing dmidecode.
      uboot-asahi = prev.uboot-asahi.overrideAttrs (old: {
        # TODO(spotlightishere): It'd be far more ideal to actually override.
        # However, somehow overriding extraConfig seems to coerce things into a string.
        # We wholly override it here, and thus should monitor to see if it changes upstream.
        extraConfig = ''
          # Upstream
          CONFIG_IDENT_STRING=" ${old.version}"
          CONFIG_VIDEO_FONT_4X6=n
          CONFIG_VIDEO_FONT_8X16=n
          CONFIG_VIDEO_FONT_SUN12X22=n
          CONFIG_VIDEO_FONT_16X32=y
          CONFIG_CMD_BOOTMENU=y

          # Custom modifications
          CONFIG_SMBIOS=y
          CONFIG_GENERATE_SMBIOS_TABLE=y
        '';
      });
    })
  ];

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
