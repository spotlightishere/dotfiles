final: prev: {
  ipsw = prev.callPackage ./ipsw.nix { };
  monaco-powerline = prev.callPackage ./monaco-powerline/default.nix { };
  telnet = prev.callPackage ./telnet.nix { };
  corellium-cli = prev.callPackage ./corellium-cli/default.nix { };

  # We'll additionally upgrade several existing packages.
  libtatsu = prev.callPackage ./libtatsu.nix { };
  libimobiledevice = prev.libimobiledevice.overrideAttrs (old: {
    version = "2025-07-01";
    src = prev.fetchFromGitHub {
      owner = "libimobiledevice";
      repo = "libimobiledevice";
      rev = "cb34a171994562a78da7ea14b801759747d0fdf7";
      hash = "sha256-lwunGrIpENVlWk6XfUD3b1KihA1+NyfvB7OO0kdE1+o=";
    };

    # libimobiledevice now requires libtatsu.
    propagatedBuildInputs = old.propagatedBuildInputs ++ [
      final.libtatsu
    ];

    patches = [ ];
  });
}
