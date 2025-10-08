{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../shared.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "flareon";
    networkmanager.enable = true;
  };

  services = {
    # We're a VM, so enable related services.
    xserver.videoDrivers = [ "qxl" ];
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;

    # Printers are scary.
    printing.enable = lib.mkForce false;

    # vscode-server
    vscode-server.enable = true;
  };

  # As we are a VM, we only want a subset of normal packages.
  environment.systemPackages = with pkgs; [
    firefox
    nix-output-monitor
    ripgrep
  ];

  services.openssh.enable = true;

  # Ensure Rosetta is available for use.
  virtualisation.rosetta.enable = true;

  # Expose Virtiofs share via UTM.
  fileSystems = {
    "/home/spotlight/Projects" = {
      device = "share";
      fsType = "virtiofs";
    };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}

