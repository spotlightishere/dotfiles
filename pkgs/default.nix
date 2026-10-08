# These are standalone packages.
# These do not require any sort of overriding whatsoever.

(final: prev: rec {
  ipsw = prev.callPackage ./ipsw.nix { };
  monaco-powerline = prev.callPackage ./monaco-powerline/default.nix { };
  telnet = prev.callPackage ./telnet.nix { };
  corellium-cli = prev.callPackage ./corellium-cli/default.nix { };
  usbfluxd = prev.callPackage ./usbfluxd.nix { };

  # TODO(spotlightishere): Fix this up, or upstream it
  pry = prev.callPackage ./pry/default.nix { };

  # TODO(spotlightishere): Similarly, upstream Frida updates.
  frida-python = import ./frida/frida-python.nix { pkgs = prev; };
  frida-tools = import ./frida/frida-tools.nix {
    inherit frida-python;
    pkgs = prev;
  };
})
