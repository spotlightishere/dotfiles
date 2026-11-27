{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-2dxZ9OA4NLNes1FOtsXDUpN/GOeKvuznqy/ygg1EH78=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-ETkrQTrUv46kzTATfylAMlNLxD/sJaundmoD0C+4C5Y=";
      platform = "manylinux2014_aarch64";
    };
    aarch64-darwin = {
      hash = "sha256-cM+Kl7lpamKC13I1MIpSQWL8qL/e9APwhPl5ixx+U+I=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.28.0";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
