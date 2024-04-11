{ config, lib, pkgs, ... }:

{
  # Custom packages.
  nixpkgs.overlays = [ (import ../pkgs/default.nix) ];

  # Commonly used packages.
  home.packages = with pkgs; [
    binwalk
    bun
    cloc
    croc
    dmg2img
    exiftool
    ffmpeg-full
    gcc-arm-embedded
    go
    google-cloud-sdk
    gradle
    htop
    # telnet
    inetutils
    imagemagick
    jadx
    jdk21
    jq
    libimobiledevice
    libusbmuxd
    meld
    monaco-powerline
    mtools
    mtr
    nodejs_21.pkgs.pnpm
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
    ripgrep
    rustup
    socat
    swiftformat
    tmux
    unar
    virt-manager
    watch
    wget
    xz
    yt-dlp
    zola
    zstd
  ];
}
