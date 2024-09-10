self: super:
{
  ipsw = super.callPackage ./ipsw.nix { };
  monaco-powerline = super.callPackage ./monaco-powerline/default.nix { };
  swiftformat = super.callPackage ./swiftformat.nix { };
}
