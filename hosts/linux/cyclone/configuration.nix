{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../shared.nix
  ];

  networking = {
    hostName = "cyclone";
    hostId = "79696666";
    # Allow WireGuard.
    firewall.checkReversePath = "loose";
  };

  # General service configuration.
  services = {
    # Ensure xserver is using the Nvidia drivers.
    xserver.videoDrivers = [ "nvidia" ];

    # Allow for RDP access.
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
    syncthing.enable = true;
  };

  hardware = {
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
      "steam-unwrapped"
    ];
  };

  # Standard system utilities. Many of these are within ../shared.nix.
  # The bulk of user-specific packages should go within the home-manager configuration.
  environment.systemPackages = with pkgs; [
    cider
    discord
    (prismlauncher.override {
      jdks = [ pkgs.jdk23 ];
    })
    vscode
  ];

  programs = {
    adb.enable = true;
    steam.enable = true;
  };

  # Docker support
  boot.kernel.sysctl."net.ipv4.ip_forward" = true;
  networking.firewall.trustedInterfaces = [ "docker0" ];
  users.users.spotlight.extraGroups = [ "adbusers" "docker" ];
  virtualisation.docker.enable = true;
  # Docker NVIDIA runtime support
  hardware.nvidia-container-toolkit.enable = true;

  # Please do not change this without reviewing release notes upstream.
  system.stateVersion = "24.11";
}
