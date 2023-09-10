self: super:
{
  monaco-powerline = super.callPackage ./monaco-powerline/default.nix {};
  swiftformat = super.callPackage ./swiftformat.nix {};

  # Include gnome-icon-theme to virt-manager to fix broken icons.
  virt-manager = super.virt-manager.override {
    preFixup = super.virt-manager.preFixup ''
      --prefix XDG_DATA_DIRS : "${super.hicolor-icon-theme}/share"
    '';
  };
}
