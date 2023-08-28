{ config, lib, pkgs, ... }:

{
  # Custom packages.
  nixpkgs.overlays = [ (import ../pkgs/default.nix) ];

  # Commonly used packages.
  home.packages = with pkgs; [
    bazelisk
    binwalk
    cloc
    croc
    exiftool
    ffmpeg
    go
    google-cloud-sdk
    gradle
    htop
    imagemagick
    jadx
    jdk
    jq
    meld
    monaco-powerline
    mtools
    mtr
    ncdu
    neofetch
    nixopsUnstable
    p7zip
    pngcrush
    pry
    protobuf
    pwgen
    qemu
    radare2
    rustup
    swiftformat
    tmux
    unar
    virt-manager
    watch
    wget
    xz
    yt-dlp
  ];

  # GPG
  programs.gpg.enable = true;
  home.file.".gnupg/gpg-agent.conf" = lib.mkIf pkgs.stdenv.isDarwin {
    text = ''
      pinentry-program "${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac"
    '';
  };

  # password-store
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [exts.pass-otp]);
    settings = {
      PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
    };
  };
}
