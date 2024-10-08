{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ]

  networking = {
    hostName = "cyclone";
    domain = "host.fox-int.cloud";
    hostId = "79696666";
    networkmanager.enable = true;
    # useNetworkd = true;

    # Use a set of known-good nameservers.
    nameservers = [
      # Quad9
      "2620:fe::fe"
      "9.9.9.9"
      # Cloudflare
      "2606:4700:4700::1111"
      "1.1.1.1"
    ];
  };

  nix.settings = {
    experimental-features = [ "flakes" "nix-command" ];
    trusted-users = [ "spotlight" ];
    builders-use-substitutes = true;

    # Include Garnix
    extra-substituters = [ "https://cache.garnix.io" ];
    extra-trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
  };

  # Select internationalisation properties.
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  # General service configuration.
  services = {
    xserver = {
      enable = true;

      # GNOME!
      desktopManager.gnome.enable = true;
      displayManager.gdm = {
        # At the login screen, don't automatically fall asleep.
        autoSuspend = false;
        enable = true;
      };

      # Nvidia driver support.
      videoDrivers = [ "nvidia" ];
    };

    # CUPS might be nice.
    printing.enable = true;

    # Audio support.
    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    gnome.gnome-remote-desktop.enable = true;

    # We'd like SSH available.
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    tailscale.enable = true;
    vscode-server.enable = true;
  };

  hardware = {
    # Pipewire conflicts with PulseAudio.
    pulseaudio.enable = false;

    # Nvidia
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;

      # The open source drivers are now recommended.
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };

    # AMD
    cpu.amd.updateMicrocode = true;
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

  # Hey, world!
  users.users.spotlight = {
    isNormalUser = true;
    extraGroups = [ "libvirtd" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQQO+c8ygVzRt55Z9qekqItSjYiw381cFPOqX+vGAGT MacBook Air 2020 macOS"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ/gyX9b80oml6z3UGOxVMJk/NS8R5w9NEITJcKb0MnU MacBook Air 2020 NixOS"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICpZtyCO6581/FdJHqSTXiFZ2XcxmUudP3sw7jjTzLiN Termius"
    ];
    shell = pkgs.zsh;
  };

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";

    # Regretfully, we use a few non-free packages:
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      # Nvidia
      "nvidia-x11"
      "nvidia-settings"
      "nvidia-persistenced"
      # Visual Studio Code
      "vscode"
      # Discord
      "discord"
      # Steam
      "steam"
      "steam-original"
      "steam-run"
    ];
  };

  # Standard system utilities.
  # The bulk of user-specific packages should go within the home-manager configuration.
  environment.systemPackages = with pkgs; [
    cider
    discord
    firefox
    htop
    git
    gnome-tweaks
    gnomeExtensions.appindicator
    seafile-client
    telegram-desktop
    tmux
    vim
    wget
  ];

  programs = {
    gnupg.agent.enable = true;
    steam.enable = true;
    zsh.enable = true;
  };

  # Please do not change this without reviewing release notes upstream.
  system.stateVersion = "24.11";
}
