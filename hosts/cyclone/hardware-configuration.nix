{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    # We'll use systemd-boot.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    # Use the latest kernel.
    # As such, we'll also use unstable ZFS.
    kernelPackages = pkgs.linuxPackages_latest;
    zfs = {
      package = pkgs.zfs_unstable;
      # For reasons unbeknownst to humanity, this drive
      # appears to keep changing identifiers or similar.
      # Prefer by-partuuid instead.
      #
      # (We could also do by-uuid, but it'd be best not
      # to have a drive's serial number publicly.)
      devNodes = "/dev/disk/by-uuid";
    };

    kernelModules = [ "kvm-amd" ];
  };

  # Configured ZFS datasets.
  fileSystems = {
    "/" = {
      device = "rpool/ROOT/nixos";
      fsType = "zfs";
    };

    "/home" = {
      device = "rpool/home";
      fsType = "zfs";
    };

    "/home/spotlight" = {
      device = "rpool/home/spotlight";
      fsType = "zfs";
    };

    "/root" = {
      device = "rpool/root";
      fsType = "zfs";
    };

    "/var/lib" = {
      device = "rpool/var/lib";
      fsType = "zfs";
    };

    "/var/log" = {
      device = "rpool/var/log";
      fsType = "zfs";
    };

    "/nix" = {
      device = "rpool/nix";
      fsType = "zfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/6073-ACA7";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };

  # ZFS is not a fan of swap.
  swapDevices = [ ];
}
