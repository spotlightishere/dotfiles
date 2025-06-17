{ pkgs, ... }: {
  ipsw = pkgs.callPackage ./ipsw.nix { };
  monaco-powerline = pkgs.callPackage ./monaco-powerline/default.nix { };
  telnet = pkgs.callPackage ./telnet.nix { };
}
