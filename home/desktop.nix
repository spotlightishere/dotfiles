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
    go
    google-cloud-sdk
    htop
    hyfetch
    imagemagick
    ipsw
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
    protobuf
    python313
    pwgen
    qemu
    radare2
    ripgrep
    rustup
    socat
    swiftformat
    telnet
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
