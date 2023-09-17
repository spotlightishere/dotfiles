self: super:
{
  monaco-powerline = super.callPackage ./monaco-powerline/default.nix { };
  swiftformat = super.callPackage ./swiftformat.nix { };
}
