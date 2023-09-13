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
    dmg2img
    exiftool
    ffmpeg
    gcc-arm-embedded
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
    nmap
    neofetch
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
    zola
  ];
}
