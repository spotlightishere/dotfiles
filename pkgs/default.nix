{ pkgs, ... }: {
  ipsw = pkgs.callPackage ./ipsw.nix { };
  monaco-powerline = pkgs.callPackage ./monaco-powerline/default.nix { };
  telnet = pkgs.callPackage ./telnet.nix { };
  corellium-cli = pkgs.callPackage ./corellium-cli/default.nix { };

  # We'll additionally upgrade several existing packages.
  libtatsu = pkgs.callPackage ./libtatsu.nix { };
  libimobiledevice = pkgs.callPackage ./libimobiledevice.nix { };
}
