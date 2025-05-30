{ pkgs, ... }: {
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

  # Similarly, enforce baseline localisation.
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  # Some common services:
  services = {
    # We'd like Bonjour available.
    avahi = {
      enable = true;
      # Enable .local resolution
      nssmdns4 = true;
    };

    # We should have GNOME on all desktop installs.
    desktopManager.gnome.enable = true;
    displayManager.gdm = {
      # At the login screen, don't automatically fall asleep.
      autoSuspend = false;
      enable = true;
    };

    # We'd also like printing support.
    printing.enable = true;

    # We want proper sound support.
    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    # Pipewire conflicts with PulseAudio.
    pulseaudio.enable = false;

    # As Mozilla's Location Service has shut down,
    # we'll use geolocation via the Arch Linux API key.
    geoclue2 = {
      enable = true;
      geoProviderUrl = "https://api.beacondb.net/v1/geolocate";

      # Let's be generous :)
      submitData = true;
      submissionUrl = "https://api.beacondb.net/v2/geosubmit";
      submissionNick = "geoclue";
    };
  };

  # Our user!
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

  # At a minimum, we'd like GnuPG and ZSH available.
  programs = {
    gnupg.agent.enable = true;
    zsh.enable = true;
  };

  # Common utilities across most Linux installs.
  environment.systemPackages = with pkgs; [
    # Since not all applications are currently GTK 4,
    # we need to manually add the Adwaita GTK 3 dark mode theme.
    adw-gtk3
    firefox
    git
    github-desktop
    gnome-tweaks
    gnomeExtensions.appindicator
    htop
    jdk24
    minicom
    pciutils
    seafile-client
    telegram-desktop
    transmission_4-gtk
    tmux
    usbutils
    vim
    wget
    wl-clipboard
  ];
}
