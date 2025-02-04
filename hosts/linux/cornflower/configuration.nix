# TODO(spotlightishere): Find a better way to disable desktop-specific components 
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader = {
    # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
    grub.enable = false;
    # Enables the generation of /boot/extlinux/extlinux.conf
    generic-extlinux-compatible.enable = true;
  };

  # We want to ensure flakes, new Nix commands,
  # and Garnix are available across all installs.
  nix.settings = {
    experimental-features = [ "flakes" "nix-command" ];
    trusted-users = [ "spotlight" ];
    builders-use-substitutes = true;

    # Include Garnix
    substituters = [ "https://cache.garnix.io" ];
    trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
  };

  # We generally want these network preferences across all installs.
  networking = {
    hostName = "cornflower";
    domain = "host.fox-int.cloud";
    networkmanager = {
      enable = true;
      # https://wiki.nixos.org/wiki/NixOS_on_ARM/Raspberry_Pi_4#Networking
      wifi.powersave = false;
    };

    nameservers = [
      # Quad9
      "2620:fe::fe"
      "9.9.9.9"
      # Cloudflare
      "2606:4700:4700::1111"
      "1.1.1.1"
    ];
  };

  # Similarly, enforce baseline localisation.
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  # We'd like Bonjour available.
  services = {
    avahi = {
      enable = true;
      # Enable .local resolution
      nssmdns4 = true;
    };
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  # Our user!
  users.users.spotlight = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQQO+c8ygVzRt55Z9qekqItSjYiw381cFPOqX+vGAGT MacBook Air 2020 macOS"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ/gyX9b80oml6z3UGOxVMJk/NS8R5w9NEITJcKb0MnU MacBook Air 2020 NixOS"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICpZtyCO6581/FdJHqSTXiFZ2XcxmUudP3sw7jjTzLiN Termius"
    ];
    shell = pkgs.zsh;
  };

  # At a minimum, we'd like ZSH available.
  programs.zsh.enable = true;

  # Common utilities across most Linux installs.
  environment.systemPackages = with pkgs; [
    htop
    git
    neofetch
    tmux
    usbutils
    vim
    wget
  ];

  # Please do not change this without reviewing release notes upstream. 
  system.stateVersion = "25.05"; # Did you read the comment?
}

