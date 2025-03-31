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

    # Where possible, we'd like to use the latest kernel version,
    # alongside the latest version of ZFS.
    #
    # The latest version of ZFS (as of writing, 2.3.1)
    # supports kernel 6.14 with no changes necessary.
    #
    # We'll temporarily override it to not mark it as broken.
    kernelPackages = pkgs.linuxPackages_6_14.extend (final: prev: {
      zfs_unstable = prev.zfs_unstable.overrideAttrs (oldAttrs: {
        # Well.. that's partially a lie, it does need
        # one patch to specify it's compatible.
        patches = [
          (pkgs.fetchpatch {
            url = "https://patch-diff.githubusercontent.com/raw/openzfs/zfs/pull/17172.patch";
            hash = "sha256-c8YP1a36uwYvvW+h4yT6s3PIKkHq6IMjVal2CcNI4p4=";
          })
        ];
        meta.broken = false;
      });
    });

    zfs = {
      package = pkgs.zfs_unstable.overrideAttrs (oldAttrs: rec {
        meta.broken = false;
      });
      # For reasons unbeknownst to humanity, this drive
      # appeared to keep changing identifiers.
      #
      # We're forcing its device to be read from by-uuid.
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
