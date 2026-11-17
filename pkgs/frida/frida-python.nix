{ pkgs }:
let
  # stdenvNoCC allows us to determine the targeted platform.
  system = pkgs.stdenvNoCC.hostPlatform.system;
  wheelMetadata = {
    x86_64-linux = {
      hash = "sha256-F1ZH1eorHU2quMHWJjT/MPwUgoBpzoJcjntbmzESUk8=";
      platform = "manylinux1_x86_64";
    };
    aarch64-linux = {
      hash = "sha256-6rrqEzTHnLvuAsnnSMTzkKo4ERfrAD0Ut6ltJYvsfZw=";
      platform = "manylinux2014_aarch64";
    };
    aarch64-darwin = {
      hash = "sha256-b7yB1XIxy/9Czm8TuPggqzFxCFHo54IRcNSEMb+hnAo=";
      platform = "macosx_11_0_arm64";
    };
  }.${system} or (throw "Unsupported system: ${system}");

  # Our actual frida-python package, the "frida" package.
in
pkgs.python3Packages.frida-python.overrideAttrs (old: rec {
  version = "17.27.0";

  src = old.src.override {
    inherit version;

    hash = wheelMetadata.hash;
    platform = wheelMetadata.platform;
  };
})
