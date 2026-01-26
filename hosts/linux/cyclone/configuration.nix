{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../shared.nix
  ];

  # Allow RISC-V emulation.
  boot.binfmt = {
    emulatedSystems = [ "riscv64-linux" ];
    preferStaticEmulators = true;
  };

  networking = {
    hostName = "cyclone";
    hostId = "79696666";
    firewall = {
      enable = false;
      # Allow WireGuard.
      checkReversePath = "loose";

      interfaces = {
        # Syncthing
        "enp14s0" = {
          allowedTCPPorts = [ 22000 ];
          allowedUDPPorts = [ 21027 ];
        };
        "tailscale0" = {
          allowedTCPPorts = [ 22000 ];
          allowedUDPPorts = [ 21027 ];
        };
      };
    };
  };

  # General service configuration.
  services = {
    # Ensure xserver is using the Nvidia drivers.
    xserver.videoDrivers = [ "nvidia" ];

    # iOS tethering, etc
    usbmuxd.enable = true;

    fwupd.enable = true;

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

    # Ensure Syncthing has the ability to write
    # within the user's home directory.
    syncthing = {
      enable = true;
      user = "spotlight";
      group = "users";
      dataDir = "/home/spotlight";
    };
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

    # Docker NVIDIA runtime support
    nvidia-container-toolkit.enable = true;

    # AMD
    cpu.amd.updateMicrocode = true;
  };

  # Container programs
  boot.kernel.sysctl."net.ipv4.ip_forward" = true;
  networking.firewall.trustedInterfaces = [ "docker0" "incusbr0" ];
  users.users.spotlight.extraGroups = [ "adbusers" "docker" "incus-admin" ];

  virtualisation = {
    # Docker
    docker.enable = true;

    # Incus (LXD)
    incus.enable = true;

    # As recommended in https://nixos.wiki/wiki/Libvirt#Setup
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
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
      # IntelliJ
      "idea"
    ];
  };

  # Standard system utilities. Many of these are within ../shared.nix.
  # The bulk of user-specific packages should go within the home-manager configuration.
  environment.systemPackages = with pkgs; [
    android-tools
    blender
    cider
    discord
    fractal
    # https://github.com/NixOS/nixpkgs/issues/425328#issuecomment-3073728060
    (jetbrains.idea.override {
      jdk = jdk25;
    })
    srain
    tcpdump
    tuba
    wireshark
    vscode
  ];

  programs.steam.enable = true;

  # Please do not change this without reviewing release notes upstream.
  system.stateVersion = "24.11";
}
