self: super:
{
  monaco-powerline = super.callPackage ./monaco-powerline/default.nix { };
  # Building with Swift requires using the Clang stdenv.
  # For more information: https://github.com/NixOS/nixpkgs/issues/242779#issuecomment-1732558769
  swiftformat = super.callPackage ./swiftformat.nix { stdenv = self.pkgs.clangStdenv; };
}
