{ pkgs, ... }: {
  ipsw = pkgs.callPackage ./ipsw.nix { };
  monaco-powerline = pkgs.callPackage ./monaco-powerline/default.nix { };
  telnet = pkgs.callPackage ./telnet.nix { };
  corellium-cli = pkgs.callPackage ./corellium-cli/default.nix { };
}
