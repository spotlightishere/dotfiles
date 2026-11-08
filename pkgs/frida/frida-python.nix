{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-gb+F0GV+77muXvkyp2GORgU0prr8G94Kaqd9f1dS61o=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-9sUaarEDj1S8N8APql+26X67p8xDhNelyUnpRvwwcTI=";
      platform = "manylinux2014_aarch64";
    };
    x86_64-darwin = {
      hash = "sha256-TdEOn/TXtHPliPlwpWwfMvyDA1o7nTrn+C2fAtCwbJs=";
      platform = "macosx_10_13_x86_64";
    };
    aarch64-darwin = {
      hash = "sha256-59sYvYjtkqrkJcnZZAANybTbn1IfJ9mkuWpueIzUVXY=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.26.2";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
