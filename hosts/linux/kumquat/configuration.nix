{ lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  # We want to ensure flakes, new Nix commands,
  # and Garnix are available across all installs.
  nix.settings = {
    experimental-features = [ "flakes" "nix-command" ];
    trusted-users = [ "spotlight" ];
    builders-use-substitutes = true;

    # Include Garnix and the RISC-V cache
    substituters = [
      "https://cache.garnix.io"
      "https://cache.ztier.in"
    ];
    trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "cache.ztier.link-1:3P5j2ZB9dNgFFFVkCQWT3mh0E+S3rIWtZvoql64UaXM="
    ];
  };

  # We generally want these network preferences across all installs.
  networking = {
    hostName = "kumquat";
    domain = "host.fox-int.cloud";
    networkmanager.enable = true;
    nftables.enable = true;

    nameservers = [
      # Quad9
      "2620:fe::fe"
      "9.9.9.9"
      # Cloudflare
      "2606:4700:4700::1111"
      "1.1.1.1"
    ];
  };

  # Allow GNOME to dynamically set the
  # time zone based on current location.
  #
  # https://www.reddit.com/r/NixOS/comments/1411gjs/comment/jo4wau3/
  time.timeZone = lib.mkForce null;
  i18n.defaultLocale = "en_US.UTF-8";

  # Some common services:
  services = {
    # We'd like Bonjour available.
    avahi = {
      enable = true;
      # Enable .local resolution
      nssmdns4 = true;
    };

    openssh.enable = true;
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

  programs = {
    gnupg.agent.enable = true;
    zsh.enable = true;
  };

  # Common utilities across most Linux installs.
  environment.systemPackages = with pkgs; [
    git
    htop
    vim
    wget
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "orangepi-xunlong-firmware"
    "orangepi-xunlong-firmware-master"
  ];

  system.stateVersion = "25.11";
}
