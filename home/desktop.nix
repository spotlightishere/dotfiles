{ config, lib, pkgs, ... }:

{
  # Commonly used packages.
  home.packages = with pkgs; [
    aria2
    binwalk
    bun
    cachix
    # clang-format
    clang-tools
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
    imagemagick
    # telnet
    inetutils
    ipsw
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
    python313
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
