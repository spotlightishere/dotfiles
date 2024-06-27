{ config, lib, pkgs, ... }:

{
  # Commonly used packages.
  home.packages = with pkgs; [
    binwalk
    bun
    cachix
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
    hyfetch
    # telnet
    inetutils
    imagemagick
    jadx
    jdk21
    jq
    libimobiledevice
    libusbmuxd
    meld
    minicom
    monaco-powerline
    mtools
    mtr
    nix-output-monitor
    nodejs_22.pkgs.pnpm
    ncdu
    nmap
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
