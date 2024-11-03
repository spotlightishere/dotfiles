# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{

  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [ "flakes" "nix-command" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  # GPU enablement
  hardware.asahi = {
    peripheralFirmwareDirectory = /boot/asahi;
    # GPU enablement
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
    withRust = true;
  };

  networking = {
    hostName = "spotlights-macbook-air";
    wireless.iwd = {
      enable = true;
      settings.General.EnableNetworkConfiguration = true;
    };
    networkmanager.enable = true;
  };

  services = {
    # Enable GNOME
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
    avahi = {
      enable = true;
      # Enable .local resolution
      nssmdns4 = true;
    };

    # Enable CUPS to print documents.
    printing.enable = true;
  };

  # Our user account.
  programs.zsh.enable = true;
  users.users.spotlight = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    cachix
    firefox
    git
    htop
    gnomeExtensions.appindicator
    legcord
    minicom
    nix-output-monitor
    python3
    seafile-client
    telegram-desktop
    tmux
    usbutils
    vim
    vscode
    wget
  ];

  # :(
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "vscode"
  ];

  # Allow location services.
  location.provider = "geoclue2";
  services.geoclue2.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  system.stateVersion = "24.05";
}
