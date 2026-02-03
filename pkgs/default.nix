# These are standalone packages.
# These do not require any sort of overriding whatsoever.

(final: prev: {
  ipsw = prev.callPackage ./ipsw.nix { };
  monaco-powerline = prev.callPackage ./monaco-powerline/default.nix { };
  telnet = prev.callPackage ./telnet.nix { };
  corellium-cli = prev.callPackage ./corellium-cli/default.nix { };
  usbfluxd = prev.callPackage ./usbfluxd.nix { };

  # TODO(spotlightishere): Fix this up, or upstream it
  pry = prev.callPackage ./pry/default.nix { };

  # TODO(spotlightishere): Similarly, upstream Frida updates.
  # Due to the length of wheel hashes, we override in a separate file.
  frida-tools = import ./frida-tools.nix { pkgs = prev; };
})
